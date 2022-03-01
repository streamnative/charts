let fs = require('fs')
// let request = require('request')
let request = require('sync-request');

let token = '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'
var url = 'https://api.github.com/repos/streamnative/charts'

function generateImage() {
  let snPRelease = getRequest(url + '/releases')
  let releaseList = JSON.parse(snPRelease.getBody('utf8')).filter(v => {return v.tag_name.includes('sn-platform')})
  let contentList = []
  releaseList.forEach(element => {
    let content = getRequest(url + '/contents/charts/sn-platform/values.yaml?ref=' + element.tag_name)
    // let fileValue = JSON.parse(content.getBody('utf8')).find(ele => ele.name == 'values.yaml')
    // console.log(JSON.parse(content.getBody('utf8')))
    contentList.push(JSON.parse(content.getBody('utf8')))
  });
  // console.log(snPRelease.getBody('utf8'))
  fs.writeFileSync('./snPRelease.json', contentList)

}

function getRequest(url) {
  return res = request('GET', url, {
    headers: {
      'User-Agent': 'request',
      'Authorization': token
    },
    json: true
  })
}

generateImage()







