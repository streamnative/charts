#!/usr/bin/env python3

import docker
import argparse
import yaml
import logging

logging.basicConfig(format='%(asctime)s %(message)s', level=logging.INFO)

class Image(object):
    def __init__(self, image = '', repository = None, tag = None) -> None:
        super().__init__()
        if repository != None and tag != None:
            self.repository = repository
            self.tag = tag
            return
        parts = image.split(':')
        if len(parts) != 2:
            raise ValueError(f"invalid image {image}")
        self.repository = parts[0]
        self.tag = parts[1]
    
    def __str__(self) -> str:
        return f"{self.repository}:{self.tag}"


class RegistryImageSink(object):
    def __init__(self, docker_client, target_registry) -> None:
        super().__init__()
        self.docker_client = docker_client
        self.target_registry = target_registry
    
    def to_target_image(self, image):
        pos = image.repository.rfind('/')
        if pos < 0:
            repo_name = image.repository
        else:
            repo_name = image.repository[pos + 1:]
        return Image(repository=f"{self.target_registry}/{repo_name}", tag=image.tag)

    def export_image(self, image, docker_img):
        target_image = self.to_target_image(image)
        docker_img.tag(target_image.repository, target_image.tag)
        logging.info(f"Tagged image {image} as {target_image}")
        self.docker_client.images.push(target_image.repository, target_image.tag)
        logging.info(f"Pushed image {target_image}")


class ImagesExporter(object):
    def __init__(self, config_path) -> None:
        super().__init__()
        with open(config_path, 'r') as f:
            self.config = yaml.load(f, yaml.Loader)
            logging.info(f"Loaded config {self.config}")
        self.docker_client = docker.from_env()
        self.sinks = []
        for sink_cfg in self.config["targets"]:
            if 'registry' in sink_cfg:
                self.sinks.append(RegistryImageSink(self.docker_client, sink_cfg['registry']))
            else:
                raise ValueError(f"invalid sink config {sink_cfg}")
        
        if len(self.sinks) == 0:
            raise ValueError("no targets")

    def export_image(self, image_str):
        image = Image(image_str)
        logging.info(f"To export image {image}")
        docker_img = self.docker_client.images.pull(image.repository, image.tag)
        logging.info(f"Pulled image {image}, id: {docker_img.id}")
        list(map(lambda sink: sink.export_image(image, docker_img), self.sinks))
    
    def export(self):
        list(map(self.export_image, self.config['images']))

def parse_args():
    parser = argparse.ArgumentParser(description='Export images required by charts')
    parser.add_argument('-c', '--config', default='config.yaml')
    return parser.parse_args()


def main():
    args = parse_args()
    exporter = ImagesExporter(args.config)
    exporter.export()


if __name__ == '__main__':
    main()