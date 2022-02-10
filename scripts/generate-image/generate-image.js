let fs = require('fs')
let request = require('request')

var repo = "streamnative/charts";
let token = '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'
var url = 'https://api.github.com/repos/streamnative/charts/releases'

function getRelease() {
  request.get(url, {
    headers: {
      'User-Agent': 'request',
      'Authorization': token
    },
    json: true
  },(err, res, body) => {
    if (err) return
    // console.log(body)
    let snPRelease = body.filter(v => {
      return v.tag_name.includes('sn-platform')
    })
    // console.log(snPRelease)
    fs.writeFileSync('./snPRelease.json', JSON.stringify(snPRelease))
  })
}

getRelease()











// var getIssueOptions = {
//   url: url
// }

// function getRelease() {
//   return new Promise(function(resolve,reject){
//       var requestC = request.defaults({jar: true});
//       console.log("Step1: get issue via url: " + url );

//       requestC(getIssueOptions,function(error,response,body){
//         if(error){
//           console.log("error occurred: " + error);
//           reject(error);
//         }
//         console.log("title:" + body.title);
//         console.log("body: " + body.body);
//       }); 
//      });
// }
