<!DOCTYPE html><html>
<heaD><meta charset="utf8"/>
<!--
<script src="https://cdn.jsdelivr.net/npm/showdown@latest/dist/showdown.min.js" type=text/javascript></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/showdown/1.9.1/showdown.min.js" type=text/javascript></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/js-yaml/3.14.0/js-yaml.min.js" type=text/javascript></script>
-->
<script src="../js/showdown.min.js" type=text/javascript></script>
<script src="../js/js-yaml.js" type=text/javascript></script>
<script src="https://unpkg.com/multihashes/dist/index.min.js"></script>
</head>
<body>
<script class=md type=text/markdown>
---
tics: 1606136752
network: godNet
uuid: 032f223c-a6c3-5fc8-9805-bc6220caadf6
gen: QmbU6tikvASzurtA6byoLvJmw6phPc14i6WwDbjhXFcTjS
prev: ~
---
# This is {{page.network}}'s Charter

network UUID = {{page.uuid}}

charter genesis template : [{{page.gen}}][gen]

[gen]: http://127.0.0.1:8080/ipfs/{{page.gen}}

## see also [RFC 4122](https://duckduckgo.com/?q=RFC+4122+)

```sh
# for sh
this="$(cat <<-EOM
{{base64.code}}
EOM
)"
echo "$this" | base64 -d | sh /dev/stdin {{page.network}}
```

<!--
```bash
read -d '' this <<EOM
{{...}}
EOM

echo "$this" | base64 -d | sh /dev/stdin {{page.network}}
```
-->

</script>
<script>
  elements = document.getElementsByTagName('script');
  console.dir(elements)
  console.log('e[2].src:',elements[2].src);
  if (elements[1].src == '' ) {
    elements[1].parentNode.removeChild(elements[1]); // remove firefox injected script
  }
  for (let i = 0; i < elements.length; i++) {
    let e = elements[i];
    if (e) {
      console.log('e:',e)
    }
  }

  let html = document.getElementsByTagName('html')[0].innerHTML;
  let doc = "<DOCTYPE html>\n" + document.getElementsByTagName('html')[0].outerHTML;
  
  let md = document.getElementsByClassName('md')[0].innerHTML;
  let pos = md.indexOf("---\n",4);
  let fmyaml = md.substr(0,pos);
  let page = window.jsyaml.safeLoad(fmyaml);
  console.log('page:',page);
  let buf = md.substr(pos+4);
  for (let key in page) {
    buf = buf.replace(new RegExp(`{{page.${key}}}`,'g'),page[key]);
  }
  console.log('buf:',buf);
  if ( typeof(showdown) == 'undefined' ) {
     document.getElementsByTagName('body')[0].innerHTML = "/!\\ markdown not loaded";
  } else {
     var converter = new showdown.Converter();
     document.getElementsByTagName('body')[0].innerHTML = converter.makeHtml(buf);
   }
</script>
</body>
</html>
