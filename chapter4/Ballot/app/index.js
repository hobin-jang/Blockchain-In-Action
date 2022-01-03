var express = require("express");
var app = express();
app.use(express.static("src"));
app.use(express.static("../contract/build/contracts"));

// index.html : 웹 앱 렌딩 페이지
app.get('/', function (req, res) {
    res.render('index.html');
});

// node.js 서버 포트 : 3000
app.listen(3000, function() {
    console.log('Example app listening on port 3000! ');
})