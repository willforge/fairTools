// ipfs routines
//
// deps:
//  - config.js
//  - essential.js
//  - sha256.min.js
//
// see also: https://www.jsdelivr.com/package/gh/mychelium/js?path=dist&version=ca0824a
// <script>
// <script src="https://cdn.jsdelivr.net/gh/mychelium/js@ca0824a/dist/sha256.min.js" integrity="sha256-YIafx9wlTYK6CHM0cY15DbyqIN2pA/Yy4QpMrwf9Cpg=" crossorigin="anonymous"></script>
// <script src="https://cdn.jsdelivr.net/gh/michel47/snippets@0.7.8/js/essential.js" integrity="sha256-FQCrKCV4H4gAfinouKXwvLZ2SHzYHhBwvPlqVnH0EAs=" crossorigin="anonymous"></script>
//
// Log:
//  console.log => console.debug by Emile Achadde 27 août 2020 at 16:15:22+02:00
// ---


(function(){ //[

 var ipfs = {
  api_url: read_api_url(), // 'http://127.0.0.1:5001/api/v0/'
  gw_url: 'http://127.0.0.1:8080', // TODO: read_gw_url ...
  ipns_cache: { 'QmezgbyqFCEybpSxCtGNxfRD9uDxC53aNv5PfhB3fGUhJZ':'/ipfs/bafyaabakaieac' },
  bootstrapNode: '/ip4/212.129.2.151/tcp/24001/ws/p2p/Qmd2iHMauVknbzZ7HFer7yNfStR4gLY1DSiih8kjquPzWV',
  bootstrapPeer: 'Qmd2iHMauVknbzZ7HFer7yNfStR4gLY1DSiih8kjquPzWV',
  peerid: null
 };

const getPeerId = function() {

   let url = ipfs.api_url + 'config?&arg=Identity.PeerID&encoding=json';
   return fetch(url,{ method: 'POST'} )
      .then( resp => {
         if(resp.ok) {
           console.info('getPeerId.resp.ok:',resp);
           return resp.json();
         } else {
           console.warn('getPeerId.resp.!ok:',resp);
           return Promise.reject(resp);
         }
       })
      .then( obj => {
            if (typeof(obj) != 'undefined') {
            console.info('getPeerId.obj:',obj);
            return Promise.resolve(obj.Value)
            } else {
            console.info('getPeerId.obj.undefined:',obj);
            return Promise.reject(obj)
            }
            })
   .catch(err => { return console.error('getPeerId.err:',err) })
}
ipfs.getPeerId = getPeerId;

getPeerId().then(id => {
 console.info('getPeerId.then.id:',id); // TODO should not get here on reject() !
  return ipfs.peerid = id
 })
.catch(err => {
 console.warn('getPeerId: remove api_url');
 localStorage.removeItem('api_url');
 ipfs.api_url = read_api_url();
 return console.warn('getPeerId:',err);
});


function read_api_url() {
  let api_url = localStorage.getItem('api_url');
  console.log('read_api_read.api_url:',api_url);
  if (typeof(api_url) == 'undefined' || api_url == null || api_url == '') {
     console.log('read_api_read: ask for api_url');
     api_url = prompt("Please enter api_url", 'http://127.0.0.1:5001/api/v0/');
     localStorage.setItem('api_url',api_url);
  }
  return api_url;
}


const qmNull = 'QmdfTbBqBPQ7VNxZEYEj14VmRuZBkqFbiwReogJgS1zR1n';
//var config;
//const cfg_url = 'http://127.0.0.1:1124/config.json';
//var promisedConfig = load_config(cfg_url);
var promisedGW;
var promisedPeerId;

//var thisscript = document.currentScript;
//thisscript.name = thisscript.src.replace(RegExp('.*/([^/]+)$'),"$1");
//console.log('this:',this);
var thisscript = {
  name: this.moduleName || 'ipfs_mod',
  src: this.moduleFilename || 'ipfs.js',
  version: '1.1'
}

/* if experimental then switch to '../' (i.e. use local js)
if (thisscript.className.match('exp') && document.location.href.match('michelc') ) {
   let src = thisscript.src.replace(RegExp('.*'+'/github\.(?:com|io)/'),'../');
   thisscript.remove();
   var script = document.createElement('script');
   script.src = src;
   console.log(thisscript.name+'.adding:',script.src);
   document.getElementsByTagName('head')[0].appendChild(script);
}

*/

console.log(thisscript.name+': '+thisscript.src+' ('+thisscript.version+')');

// --------------------------------------------;
// global variables ...;

 if (typeof(core) == 'undefined') {
      var core = {};
      core['name'] = 'fairRings™'
      core['index'] = 'frindex.log'
      core['dir'] = '/.../.frings';
      core['history'] = core['dir'] + '/published/history.log';
      console.log('core:',core);
 }

/* 
promisedConfig.then( cfg => {
 console.log('ipfs.promisedConfig:',promisedConfig);
 console.log('ipfs.promisedConfig.then.config:',cfg);
 configure(cfg);
})
.catch(console.error);
*/

ipfs.configure = function configure(cfg) {
   api_url = localStorage.getItem('api_url');
   if (typeof(api_url) == 'undefined' || api_url == null || api_url == '') {
      if (typeof(cfg) != 'undefined') {
         api_url = cfg.api_url;
      } else {
         api_url = 'http://127.0.0.1:5001/api/v0/';
      }
      console.info('api_url: ',api_url)
   } else {
      let el = document.getElementsByName('api_url')[0];
      if (typeof(el) != 'undefined') { el.value = api_url }
      console.info('localStorage.api_url: ',api_url)
      
   }
   promisedGW = api_config_mod.update_gw_url(api_url) // from api_config.js
   .then ( url => {
     gw_url = url;
     if (typeof(gw_url) == 'undefined' || gw_url == null || gw_url == '') {
        if (typeof(cfg) != 'undefined') {
           gw_url = cfg.gw_url;
        } else {
           gw_url = 'http://127.0.0.1:8080';
        }
     }
     console.info('config.gw_url: ',gw_url)
     return gw_url;
   })
   .catch(console.error);
   console.log('configure.promisedGW: ',promisedGW)

   //var container = document.getElementsByClassName('container');
   if (typeof(ipfsversion) == 'undefined') {
      ipfsVersion().then( v => { window.ipfsversion = v })
   } else {
      let [callee, caller] = essential.functionNameJS();
      console.info(caller+'.'+callee+'.ipfsversion: ',ipfsversion);
   }

   promisedPeerId = getPeerId();

}


// --------------------------------------------

ipfs.ipfsVersion = function ipfsVersion() {
   let url = api_url + 'version';
   return fetch(url,{ method:'POST' })
   .then( resp => resp.json() )
   .then( obj => {
      console.log('ipfs.version.obj: ',obj);
      return obj.Version; })
   .catch(console.error)
}

// loading a config via "smart-contract" side channel
ipfs.load_config = async function load_config(cfg_url) {
  return fetch(cfg_url)
  .then( resp => resp.json() )
  .then( json => {
        if (typeof(json) != 'undefined') {
          return Promise.resolve(json)
        } else {
          console.error('check if serve_config is running');
          return Promise.reject(json)
        }
  })
  .catch(console.error)
}


/* this portion of the code need to be on the app side ...
// get and replace the peer id ...
if (typeof(peerid) == 'undefined') {
    var peerid;
    getPeerId()
	.then(id => { peerid = (typeof(id) == 'undefined') ? 'QmYourIPFSisNotRunning' : id; return peerid })
    //.then( replaceNameInGlobalContainer('peerid'))
    // .then( replaceNameInClass('peerid','container') )
	.then( replacePeerIdInForm )
	.then( peerid => {
	    let s = peerid.substr(0,7);
	    console.debug('main.s:',s);
	    replaceInTagsByClassName('shortid',s)
	})
	.catch(console.error);

}

function replacePeerIdInForm(id) { 
    let [callee, caller] = essential.functionNameJS();
    console.debug(callee+'.input.id',id);

    let forms = document.getElementsByTagName('form');
    console.debug(callee+'.forms: ',forms);
    if (forms.length > 0) { 
	let e = forms[0].elements['peerid'];
	if (typeof(e) != 'undefined') {
	    console.debug(callee+'.e.outerHTML',e.outerHTML)
	    e.value = e.value.replace(new RegExp(':peerid','g'),id)
	}
    }
    return id
}
*/

ipfs.getNid = getNid = function getNid(string) {
  let [callee, caller] = essential.functionNameJS();
  console.debug(callee+'.inputs:',{string})
  let sha2 = sha256(string) // return hex string
  console.debug(callee+'.sha2:',sha2)
  let ns36 = BigInt('0x'+sha2).toString(36).substr(0,13)
  console.debug(callee+'.ns36:',ns36)
  return ns36
}

function shard_n_key(s) {
  let s2 = sha256(s)
  return [s2.substr(-4,3),s2.substr(0,18) ];

}
function getShard(s) {
   return sha256(s).substr(-4,3);
}

function hashkey(s) {
   return sha256(s).substr(0,18);
}

ipfs.shortqm = shortqm = function shortqm(qm) {
   if (typeof(qm) != 'undefined') {
      return qm.substr(0,6)+'...'+qm.substr(-3)
   } else {
      return 'undefined';
   }
}


const ipfsPeerConnect = function (peerid,layer) { // layer ∈ {ws,quic,.}
    let callee = essential.functionNameJS()[0];
    var url = ipfs.api_url + 'dht/findpeer?arg='+peerid;
    return fetch(url,{method:'POST'}).then(resp => resp.text())
     .then( text => { // TODO : convert to stream ...
       //console.debug(callee+'.text:',text);
       let ndjson = text.slice(0,-1).split('\n')
       //console.debug(callee+'.ndjson:',ndjson);
       let addr;
       let url;
       let connections = [];
       for (let record of ndjson) {
         //console.debug(callee+'.record:',record);
         let json = JSON.parse(record);
         if (json.Type != 2 || json.Responses == null) { continue; } /* 0 PeerResponse, 1 FinalPeer, 2 QueryError, 3 Provider, 4 Value, 5 AddingPeer, 6 DialingPeer */
         console.debug(callee+'.json:',json);
         for (let resp of json.Responses) {
           if (resp.ID != peerid) { continue; }
           for (let addy of resp.Addrs) {
             if (addy.match('^/ip4/')
                  && ! addy.match('/ip4/127\.') && ! addy.match('/ip4/192\.') ) {
                console.log(callee+'.addy:',addy);
               if (typeof(layer) == 'undefined' || addy.match(layer+'$')) {
                 addr = addy; // break;
                 url = ipfs.api_url + 'swarm/connect?arg='+addr+'/p2p/'+peerid;
                 let promised_connection = fetch(url,{ method:'POST' })
                  .then( resp => resp.json() )
                  .then( obj => {
                        console.log(callee+'.obj:',obj);
                        if (obj.Strings[0].match('success')) {
                        console.log(callee+': SUCCESS');
                        return true;
                        } else {
                        console.log(callee+': ERROR');
                        return Promise.reject(false);
                        }
                        })
                  .catch(console.error);
                 connections.push(promised_connection);
               }
             }
           }
         }
       }
       if (connections.length > 0) {
         return Promise.any(connections)
           .then( proms => {
            console.log(callee+'.proms:',proms);
            return proms;
           })
           .catch(console.warn);
       } else {
         return Promise.reject(callee+': no address returned');
       }
     })
    .catch(err => { console.error(err); return err});
}
ipfs.ipfsPeerConnect = ipfsPeerConnect

ipfsPeerConnect(ipfs.bootstrapPeer)
 .then( status => {
   console.log('ipfsPeerConnect.status:',status);
   return status;
 }).catch(console.warn);

function indexlogfilename(mutable) {
    let shard = getShard(mutable);
    let indexlogf = core.dir+'/shards/'+shard+'/'+core.index;
    return indexlogf
}

function ipfsPing(peer) {
    let [callee, caller] = essential.functionNameJS(); // logInfo("message !")
    var url = api_url + 'ping?arg='+peer+'&count=2';
    return fetchGetPostText(url)
    .then( obj => {
       console.debug(callee+'.obj:',obj);
    })
    .catch(console.error);
}

ipfs.ipfsPublishByPath = function ipfsPublishByPath(mfspath) {
  let [callee, caller] = essential.functionNameJS(); // logInfo("message !")
  let qmroot;
  // -------------------------------------------------------
  let url = ipfs.api_url + 'name/resolve';
  let promised_qmroot = fetch(url,{method:'POST'})
  .then(resp => resp.json())
  .then(obj => { 
    qmroot = obj.Path.replace('/ipfs/','');
    // only root mfspath (w/o subfolders) for now!
    let url = ipfs.api_url + 'object/patch/rm-link?arg='+qmroot+'&arg='+mfspath.slice(1)
    return fetch(url,{method:'POST'})
    .then(resp => resp.json())
    .catch( _ => { console.error(callee+'rm-link.error:',_); return qmroot; })
  })
  .then(obj => {
      console.log('ipfsPublishByPath.obj:',obj)
      return obj.Hash || qmroot; // new qmroot
  })
  .catch(console.warn);
  // -------------------------------------------------------
  url = ipfs.api_url + `files/stat?arg=${mfspath}&hash=true`;
  let promised_mfshash = fetch(url,{method:'POST'})
     .then(resp => resp.json())
     .then( json => { let hash = json.Hash; console.debug(callee+'.promised_mfshash:',hash); return hash; })
     .catch(console.warn);
  // -------------------------------------------------------
  return Promise.all([promised_qmroot,promised_mfshash])
  .then( results => {
    let [qmroot,mfshash] = results;
    if (typeof(mfshash) != 'undefined') {
      let url = ipfs.api_url + 'object/patch/add-link?arg='+qmroot+'&arg='+mfspath.slice(1)+'&arg='+mfshash
      return fetch(url,{method:'POST'})
      .then(resp => resp.json())
      .then(json => { return json.Hash })
      .catch(_ => {
        console.warn(callee+'add-link.warn:',_);
        return qmroot;
      })
    } else {
      console.warn(callee+'add-link.undefined:',results);
      return qmroot;
    }
  })
  // -------------------------------------------------------
  .then( qmroot => {
     console.debug(callee+'.Promise.all.qmroot:',qmroot);
     let url = ipfs.api_url + 'name/publish?key=self&arg=/ipfs/'+qmroot
     return fetch(url,{method:'POST'})
     .then(resp => resp.json())
     .then( json => { let ipath = json.Value; console.debug(callee+'.name.publish.json',json);
        return ipath.replace('/ipfs/','');
     })
     .catch(console.error);
  })
  .catch(console.warn);
}

async function ipfsPublish(pubpath) {
    let [callee, caller] = essential.functionNameJS(); // logInfo("message !")
    console.debug(callee+'.inputs:',{pubpath});
    
    let parent;
    let pname;
    let fname;
    if (pubpath.match('/./')) {
       [parent,fname] = pubpath.split('/./');
       pname=parent.substr(parent.lastIndexOf('/')+1);
       fname = pname+'/'+fname;
    } else {
       parent = pubpath;
       let p = pubpath.slice(0,-1).lastIndexOf('/'); // (remove trailing / in directories)
       console.debug(callee+'.p: ',p);
       //let grandparent = parent.substring(0,p)
       pname=parent.substr(p+1);
       fname = pname;
    }

    console.debug(callee+'.parent: ',parent);
    console.debug(callee+'.pname: ',pname);
    console.debug(callee+'.fname: ',fname);
    // get hash of parent
    let hash = await getMFSFileHash(parent);
       console.debug(callee+'.hash: ',hash);
    // get wrappper's hash of parent
    let whash = await getIpfsWrapperHash(pname,hash);
    let sha2 = sha256(parent);
    let shard = sha2.substr(-4,3);
    let key = sha2.substr(0,18); // truncate to 9 bytes
    console.debug(callee+'.parent: ',parent);
    console.debug(callee+'.sha2: ',sha2);
    console.debug(callee+'.key: ',key);
    //let record = hash+': '+parent;
    let record = key+': /ipfs/'+whash+'/'+fname+"\n";
    console.debug(callee+'.record: ',record);
    let indexlogf = core.dir+'/shards/'+shard+'/'+core.index;
    let lhash = await ipfsLogAppend(indexlogf,record);
    console.debug(callee+'.lhash:',lhash);
    let bhash = await getMFSFileHash(core.dir); // get hash of PoR
    // publish under self/peerid
    let ipath = await ipfsNamePublish('self','/ipfs/'+bhash);
    console.debug(callee+'.ipath:',ipath);
    let ppath = ipath+'/'+pname;
    console.debug(callee+'.ppath:',ppath);
    return ppath;
}


function ipfsGetKeyByName(symb) {
    let [callee, caller] = essential.functionNameJS(); // logInfo("message !")
    console.debug(callee+'.inputs:',{symb});
    var url = api_url + 'key/list?l=true&ipns-base=b58mh'
    return fetchGetPostJson(url)
	.then( json => {
      let key_obj = json.Keys.find( e => e.Name == symb )
      console.debug(callee+'.key_obj:',key_obj)
      return key_obj.Id
       
     })
	.catch(console.error)
}

function ipfsNamePublish(k,v) {
    let [callee, caller] = essential.functionNameJS(); // logInfo("message !")
    console.debug(callee+'.inputs:',{k,v});
    var url = api_url + 'name/publish?key='+k+'&arg='+v+'&allow-offline=1&resolve=0';
    return fetchGetPostJson(url)
	.then( json => { return json.Value })
	.catch(console.error)
}
ipfs.ipfsNameResolve = ipfsNameResolve = function ipfsNameResolve(k,cb) {
    let [callee, caller] = essential.functionNameJS(); // logInfo("message !")
    console.debug(callee+'.inputs:',{k});
    var url = api_url + 'name/resolve?arg='+k;
    let promise = fetchGetPostJson(url)
    .then( json => {
      ipfs.ipns_cache[k] = json.Path;
      console.trace(callee+`.info: UPDATE ipns_cache[${k}]:`,ipfs.ipns_cache[k]);
      if (typeof(cb) != 'undefined') { return cb(json.Path); }
      return json.Path
    })
    .catch(console.error);

    if (typeof(ipfs.ipns_cache[k]) != 'undefined') { 
       console.debug(callee+`.info: HIT ipns_cache[${k}]:`,ipfs.ipns_cache[k]);
       return(ipfs.ipns_cache[k]);
    } else {
      console.debug(callee+'.info: MISS promised:',promise);
      return promise;
    }
}
ipfs.ipfsResolve = ipfsResolve = function ipfsResolve(ipath) {
    let [callee, caller] = essential.functionNameJS(); // logInfo("message !")
    console.debug(callee+'.inputs:',{ipath});
    var url = ipfs.api_url + 'resolve?arg='+ipath+'&timeout=61s';
    return fetch(url,{method:'POST'}).then(resp => resp.json())
    .then( json => {
       if (typeof(json) != 'undefined') {
        return json.Path
        } else {
         return undefined
        }
    } )
	  .catch(console.error)
   
}


ipfs.ipfsProvideHash = function ipfsProvideHash(promised_hash) {
  return promised_hash.then(hash => {
    let url = ipfs.api_url + 'dht/provide?arg='+hash;
    return fetch(url,{method:'POST'})
    .then(resp => resp.text())
    .then(obj => { console.log('ipfsProvideHash:',{'obj':obj.split('\n')}); return obj })
  })
  .catch(console.warn)
}

ipfs.ipfsSetToken = function ipfsSetToken(string) { // pin=true
  let [callee, caller] = essential.functionNameJS(); // logInfo("message !")
  console.debug(callee+'.inputs:',{string});
  let url = ipfs.api_url + 'add?file=content.dat&raw-leaves=true&hash=sha3-224&only-hash=false&cid-base=base58btc&pin=true'
  let form = new FormData(); form.append('file', string);
  return fetch(url,{method:'POST',body: form})
  .then( resp => resp.json() )
  .then( json => { console.log(callee+'.json:',json); return json.Hash })
  .catch(console.error)
}
ipfs.ipfsGetToken = ipfsGetToken = function ipfsGetToken(string) { // only-hash
  let [callee, caller] = essential.functionNameJS(); // logInfo("message !")
  console.debug(callee+'.inputs:',{string});
  console.debug(callee+'.api_url:',ipfs.api_url);
  let url = ipfs.api_url + 'add?file=content.dat&raw-leaves=true&hash=sha3-224&only-hash=true&cid-base=base58btc&pin=false'
  console.debug(callee+'.url:',url);
  let form = new FormData(); form.append('file', string);
  return fetch(url,{method:'POST',body: form})
  .then( resp => resp.json() )
  .then( json => json.Hash )
  .catch(console.error)
}

ipfs.ipfsFindPeersStream = ipfsFindPeersStream = function ipfsFindPeersStream(qmtoken,streamcallback,finalcallback) {
   peers = [];
       let headers = new Headers();
       if (ipfs.api_url.match('blockring')) { headers.set('X-APIKey','nkyjXz4POzG6vijIoiQ0WWx70ceQzEyw'); }
       return fetch(ipfs.api_url+'dht/findprovs?arg='+qmtoken, { method: 'POST', headers: headers, mode:'cors' }).
         then( resp => { console.log(resp.body); return resp.body.getReader(); }).
         then( reader => { return readStream(reader,streamcallback); }).
         catch(err => { console.error('ipfsFindPeersStream.err:',err) }).
         finally( _ => { return finalcallback(peers); });

}
ipfs.readStream = readStream = function readStream(reader, callback) {
    let read;
    var buf = ''
       return reader.read().
       then(read = ({ value, done }) => {
          if (done) return buf;
          //console.debug('value.buffer:',value.buffer)
          //if (buf != '') { console.debug('buf:',buf) }
          buf += String.fromCharCode.apply(String, value);
          // spliting the NDJSON
          let lines = buf.replace(/(\n|\r)+$/, '').split("\n"); 
          buf = (lines[lines.length-1].match(/\{?\}$/)) ? '' : lines.pop();
          let objs = lines.map(JSON.parse)
          // console.log('objs:',objs)
          callback(objs);
          if (objs.length > 0) {
            return reader.read().then(read).catch(buf => { console.debug([{"buf-leftover":buf}]) } ); // recursion !
          } else {
            return Promise.reject(String.fromCharCode.apply(String, value));
          }
       });
}




ipfs.ipfsFindProvs = ipfsFindProvs = function ipfsFindProvs(key) {
   let [callee, caller] = essential.functionNameJS();
   // num-providers=20&timeout=61s
   return fetch(ipfs.api_url+'dht/findprovs?arg='+key+'&verbose=true&num-providers=4&timeout=5s',{ method:'POST', mode: 'cors' })
      .then( resp => resp.text() )
      .then( text => {
           let objs = text.replace(/(\n|\r)+$/, '').split("\n");
           let provs = objs.map( (s) => JSON.parse(s) ).filter( (o) => o.Type == 4 );
           console.debug(callee+'.provs:',provs)
           let peerids = provs.map( (o) => o.Responses[0].ID );
           return peerids;
      })
      .catch(console.error);
}

function ipfsAddToken(string) {
    let [callee, caller] = essential.functionNameJS(); // logInfo("message !")
    console.debug(callee+'.inputs:',{string});
    let url = api_url + 'add?file=content.dat&raw-leaves=true&hash=sha3-224&cid-base=base58btc&pin=true'
    return fetchPostText(url,string)
  	.then( resp => resp.json() )
  	.then( json => json.Hash )
	  .catch(console.error)
}
function ipfsAddBinaryContent(string) {
    let [callee, caller] = essential.functionNameJS(); // logInfo("message !")
    console.debug(callee+'.inputs:',{string});
    
    let url = api_url + 'add?file=content.dat&cid-version=0'
    return fetchPostBinary(url,string)
	.then( resp => resp.json() )
	.then( json => json.Hash )
	.catch(console.error)
}
function ipfsAddRawContent(string) {
    let [callee, caller] = essential.functionNameJS(); // logInfo("message !")
    console.debug(callee+'.inputs:',{string});
    let url = api_url + 'add?file=content.dat&raw-leaves=true&cid-base=base58btc'
    return fetchPostBinary(url,string)
	.then( resp => resp.json() )
	.then( json => json.Hash )
	.catch(console.error)
}

function ipfsAddBinaryFile(file) {
    let [callee, caller] = essential.functionNameJS(); // logInfo("message !")
    console.debug(callee+'.inputs:',{file});

    return readAsBinaryString(file)
	.then( buf => {
	    url = api_url + 'add?file=file.txt&cid-version=0'
	    return fetchPostBinary(url,buf)
		.then( resp => resp.json() )
		.then( json => json.Hash )
		.catch(console.error)
	})
	.catch(console.error)
}
function ipfsAddTextContent(string) {
    let [callee, caller] = essential.functionNameJS(); // logInfo("message !")
    console.debug(callee+'.inputs:',{string});
    
    url = api_url + 'add?file=content.txt&cid-version=0'
    return fetchPostText(url,string)
	.then( resp => resp.json() )
	.then( json => json.Hash )
	.catch(console.error)
}

function ipfsAddTextFile(file) {
    let [callee, caller] = essential.functionNameJS(); // logInfo("message !")
    console.debug(callee+'.inputs:',{file});

    return readAsText(file)
	.then( buf => {
	    // curl -X POST -F file=@myfile "http://127.0.0.1:5001/api/v0/add?quiet=0&quieter=0&silent=0&progress=0&trickle=0&only-hash=1
	    //  &wrap-with-directory=0&chunker=size-262144&pin=1&raw-leaves=1
	    //  &nocopy=0&fscache=1&cid-version=0&hash=sha2-256&inline=0&inline-limit=32"
	    url = api_url + 'add?file=file.txt&cid-version=0&only-hash=1'
	    return fetchPostText(url,buf)
		.then( resp => resp.json() )
		.then( json => json.Hash )
		.catch(console.error)
	})
	.catch(console.error)
}

function getJsonByMFSPath(path) {
    let [callee, caller] = essential.functionNameJS(); // logInfo("message !")
    console.debug(callee+'.inputs:',{path});

    let  url = api_url + 'files/read?arg='+path
    return fetchGetPostJson(url)
}


const mfsGetContentByPath = function(path) {
    let [callee, caller] = essential.functionNameJS(); // logInfo("message !")
    console.debug(callee+'.inputs:',{path});
    let  url = ipfs.api_url + 'files/read?arg='+path
    return fetch(url,{method:'POST',mode:'cors'}).then(resp => resp.text())
    .catch(console.warn);
}
ipfs.mfsGetContentByPath = mfsGetContentByPath;
const getMFSFileContent = mfsGetContentByPath

function ipfsGetBinaryByHash(hash) {
    let [callee, caller] = essential.functionNameJS(); // logInfo("message !")
    console.debug(callee+'.inputs:',{hash});
    url = api_url + 'cat?arg='+hash
    console.debug('url: '+url);
    return fetchGetPostBinary(url)
  	.catch(console.Error)
}

function ipfsGetContentByHash(hash) {
    let [callee, caller] = essential.functionNameJS(); // logInfo("message !")
    console.debug(callee+'.inputs:',{hash});

    url = api_url + 'cat?arg='+hash+'&timeout=300s'
    console.debug('url: '+url);
    return fetchRespCatch(url)
	.catch(console.error)
}

function ipfsGetHashBinary(hash,timeout) {
    let [callee, caller] = essential.functionNameJS(); // logInfo("message !")
    console.debug(callee+'.inputs:',{hash,timeout});
    if (typeof(timeout) == 'undefined') { timeout = 120 }
    url = api_url + 'cat?arg='+hash+'&timeout='+timeout+'s'
    console.debug('url: '+url);
    return fetchGetPostBinary(url)
  	.catch(console.error)
}

function ipfsGetHashContent(hash,timeout) {
    let [callee, caller] = essential.functionNameJS(); // logInfo("message !")
    console.debug(callee+'.inputs:',{hash,timeout});
    if (typeof(timeout) == 'undefined') { timeout = 120 }
    url = api_url + 'cat?arg='+hash+'&timeout='+timeout+'s'
    console.debug('url: '+url);
    return fetchRespCatch(url)
	  .catch(console.error)
}

const ipfsGetContentByPath = function (path) { // no timeout, no error
    url = ipfs.api_url + 'cat?arg='+path;
    return fetch(url,{method:'POST'}).then(resp => resp.text())
	  .catch(console.error)
}
ipfs.ipfsGetContentByPath = ipfsGetContentByPath;

function ipfsGetJsonByPath(path) { // no timeout
    url = api_url + 'cat?arg='+path;
    return fetchGetPostJson(url)
	.catch(console.error)
}


function ipfsGetHashByContent(buf) {
    let [callee, caller] = essential.functionNameJS(); // logInfo("message !")
    console.debug(callee+'.inputs:',[{buf}]);
    // DO NOT STORE CONTENT !
    url = api_url + 'add?only-hash=true&cid-version=0'
    console.debug(callee+'.url: '+url);
    return fetchPostBinary(url,buf)
	.then( resp => resp.json() )
	.then( json => json.Hash )
	.catch(console.error)
}
const ipfsGetContentHash  = ipfsPostHashByContent
function ipfsPostHashByContent(buf) {
    let [callee, caller] = essential.functionNameJS(); // logInfo("message !")
    console.debug(callee+'.inputs:',[{buf}]);
    url = api_url + 'add?file=blob.data&cid-version=0'
    console.debug(callee+'.url: '+url);
    return fetchPostBinary(url,buf)
	.then( resp => resp.json() )
	.then( json => json.Hash )
	.catch(console.error)
}

function ipfsPostHashByObject(obj) {
    let [callee, caller] = essential.functionNameJS(); // logInfo("message !")
    console.debug(callee+'.inputs:',{obj});
    url = api_url + 'add?file=blob.data&cid-version=0'
    console.debug(callee+'.url: '+url);
    let buf = JSON.stringify(obj);
    return fetchPostBinary(url,buf)
	.then( resp => resp.json() )
	.then( json => { console.warn(callee+'.json:',callee+'.json:',json); return json; })
	.then( json => json.Hash )
	.catch(console.error)
}



function ipfsPostSHA1ByContent(buf) {
   let [callee, caller] = essential.functionNameJS(); // logInfo("message !")
   console.debug(callee+'.inputs:',[{buf}]);
   url = api_url + 'add?file=blob.data&hash=sha1&cid-base=base58btc&only-hash=false&pin=false'
      console.debug(callee+'.url: '+url);
   return fetchPostBinary(url,buf)
      .then( resp => resp.json() )
      .then( json => {
            console.debug(callee+'.sha1:',json.Hash);
            return json.Hash
            })
      .catch(console.error)
}


function ipnsGetContentByKey(key) {
    let [callee, caller] = essential.functionNameJS(); // logInfo("message !")
    console.debug(callee+'.inputs:',{key});

    url = api_url + 'cat?arg=/ipns/'+key
    console.debug(callee+'.url: '+url);
    return fetchGetPostText(url)
	.then( obj => { console.log(callee+'.obj:',obj);
    if (typeof(obj.status) != undefined) { // error
      return obj.status + ' ' + obj.statusText
    } else {
      return obj
    }
   })
  .catch(console.error)

}

function ipfsLsofPath(ipfspath) {
    let [callee, caller] = essential.functionNameJS();
    console.debug(callee+'.inputs:',{ipfspath});
    url = api_url + 'ls?arg='+ipfspath
    console.debug(callee+'.url: '+url);
    return fetchGetPostJson(url)
	.then( json => { console.log(callee+'.json:',json); return json.Objects[0]; })
  .catch(console.error)
}

function ipfsPinAdd(hash) {
    let [callee, caller] = essential.functionNameJS(); // logInfo("message !")
    console.debug(callee+'.inputs:',{hash});

    let url = api_url + 'pin/add?arg=/ipfs/'+hash+'&progress=false'
    return fetchGetPostJson(url)
	.then(json => { console.debug(callee+'.json',json); return json })
	.catch(err => console.error(err, hash))
}

function ipfsPinRm(hash) {
    let [callee, caller] = essential.functionNameJS(); // logInfo("message !")
    console.debug(callee+'.inputs:',{hash});

    let url = api_url + 'pin/rm?arg=/ipfs/'+hash
    console.log('ipfsPinRm.url',url)
    return fetchGetPostJson(url)
	.then( json => { console.log('ipfsPinRm.json',json);
	    return json.Pins  // Improve when recursive ?
	})
	.catch(err => console.error(err, hash))
}

function toCid32(hash) { // TODO
  let bin;
  switch(true) {
  case (hash.match(/^Qm/) ):
      cidheader = hex2bin('0170');
      bin = decode_base58(hash); break;
  case (hash.match(/^z/) ):
      let mhash = decode_base58(hash.slice(1));
      cidheader = mhash.substr(0,2);
      bin = mhash.substr(2);
      break;
  default:
      console.warn(callee+'.default.unknow.hash:', hash)
      cidheader = null;
      bin = null;
  }

  let cid32 = encode_base32(cidheade + bin);
  return cid32;
}

function getPinStatus(hash) { // getdata
    let [callee, caller] = essential.functionNameJS(); // logInfo("message !")
    console.debug(callee+'.inputs:',{hash});
    let mhash
    if (hash.slice(0,1) === 'z') {
       mhash = BaseN.decode(hash.slice(1),'base58');
    } else { 
       mhash = BaseN.decode(hash,'base58');
    }
    console.debug(callee+'.mhash:',mhash);
    let b32 = Base32.encode(mhash);
    console.debug(callee+'.b32:',b32);
    let bafy = 'b'+ Base32.stringify(mhash);
    console.debug(callee+'.bafy:',bafy);
    let  url = api_url + 'pin/ls?arg=/ipfs/'+hash+'&type=all&cid-base=base58btc'
    return fetchRespNoCatch(url)
	.then( obj => {
	    let status;
      if (typeof(obj.Code) == 'undefined') {
      console.debug(callee+'.pinned.obj:',obj);
      status = obj.Keys[hash].Type
      } else {
      // console.debug(callee+'.unpinned.obj:',obj);
      status = 'unpinned'
      }
	    console.debug(callee+': '+hash+" \u21A6",status);
	    return Promise.resolve(status)
	})
	.catch( obj => { console.error('getPinStatus.catch',obj) })
}

function ipfsRmMFSFileUnless06(mfspath) {
    let [callee, caller] = essential.functionNameJS(); // logInfo("message !")
    console.debug(callee+'.inputs:',{mfspath});

    if (typeof(ipfsversion) != 'undefined' && ipfsversion.substr(0,3) == '0.6') {
       console.log('info: assumed truncates works !')
          return Promise.resolve('noop');
    } else {
       url = api_url + 'files/rm?arg='+mfspath
       return fetch(url,{method:'POST'})
          .then( resp => {
                if (resp.ok) { return resp.text(); }
                else { return resp.json(); }
          })
       .catch(console.error)
    }
}

function ipfsRmMFSFile(mfspath) {
    let [callee, caller] = essential.functionNameJS(); // logInfo("message !")
    console.debug(callee+'.inputs:',{mfspath});

    url = api_url + 'files/rm?arg='+mfspath
    return fetch(url,{method:'POST'})
	.then( resp => {
	    if (resp.ok) { return resp.text(); }
	    else { return resp.json(); }
	})
	.catch(console.error)
}

function ipfsCpMFSFile(target,source) {
    let [callee, caller] = essential.functionNameJS(); // logInfo("message !")
    console.debug(callee+'.inputs:',{target,source});

    url = api_url + 'files/cp?arg='+source+'&arg='+target;
    return fetch(url,{method:'POST'})
	.then( resp => {
	    console.log('resp: ',resp)
	    if (resp.ok) { return resp.text(); }
	    else { return resp.json(); }
	})
	.catch(console.error)
}

const ipfsWriteContent = function (mfspath,buf,options) {
    let [callee, caller] = essential.functionNameJS(); // logInfo("message !")
    console.debug(callee+'.inputs:',[{mfspath,buf}]);
    
    // truncate doesn't work for version <= 0.4 !
    // so let's do a rm before
    // return createParent(mfspath)
	  //.then(ipfsRmMFSFileUnless06(mfspath))
    let url;
    if (typeof(options) != 'undefined' && options.raw == true) {
	      url = ipfs.api_url + 'files/write?arg=' + mfspath + '&raw-leaves=true&parents=true&create=true&truncate=true';
    } else {
	      url = ipfs.api_url + 'files/write?arg=' + mfspath + '&parents=true&create=true&truncate=true';
    }
    let form = new FormData(); form.set('file', buf)
    return fetch(url, { method: "POST", mode: 'cors', body: form })
		.then( _ => ipfs.mfsGetHashByPath(mfspath)) 
		.catch(console.error)
}
ipfs.ipfsWriteContent = ipfsWriteContent

function ipfsWriteText(mfspath,buf) { // truncate doesn't work for version < 0.5 !
    let [callee, caller] = essential.functionNameJS(); // logInfo("message !")
    console.debug(callee+'.inputs:',[{mfspath,buf}]);

    return createParent(mfspath)
	.then(ipfsRmMFSFileUnless06(mfspath))
	.then( _ => {
	    var url = ipfs.api_url + 'files/write?arg=' + mfspath + '&create=true&truncate=true';
	    return fetchPostText(url, buf) // <--------
		.then( _ => getMFSFileHash(mfspath)) 
		.catch(console.error)
	})
	.catch(console.warn)
}

async function ipfsFileAppend(data,file) { // easy way: read + create !
    let [callee, caller] = essential.functionNameJS(); // logInfo("message !")
    console.debug(callee+'.inputs',{data,file});

    let buf = await getMFSFileContent(file)
    buf += data+"\n"
    console.debug(callee+'.buf:',buf)
    let status = await ipfsWriteText(file,buf);
    console.debug(callee+'.write.status:',status)
    let hash = await getMFSFileHash(file)
    console.debug(callee+'.hash: ',hash)
    return hash
}

async function ipfsShardedFileAppend(data,file) { // easy way: read + create !
    let [callee, caller] = essential.functionNameJS(); // logInfo("message !")
    console.debug(callee+'.inputs:',{data,file});

    let buf = await getMFSFileContent(file)
    buf += data+"\n"
    console.debug(callee+'.buf:',buf)
    let status = await ipfsWriteText(file,buf);
    console.debug(callee+'.write.status:',status)
    let hash = await getMFSFileHash(file)
    console.debug(callee+'.hash: ',hash)
    return hash
}

async function getIpfsWrapperHash(name,hash) {
    let [callee, caller] = essential.functionNameJS(); // logInfo("message !")
    console.debug(callee+'.inputs:',{name,hash});

    //name = name.substring(0,name.indexOf('/'));
    name = name.split('/')[0]
    console.debug(callee+'.name:',name);
    const emptyd = 'QmUNLLsPACCz1vLxQVkXqqLX5R1X345qqfHbsf67hvA3Nn';
    var url = api_url + 'object/patch/add-link?arg='+emptyd +'&arg=' + name + '&arg=' + hash;
    let obj = await fetch(url,{ method: "POST"} ).then( resp => resp.json() ).catch(console.error)
    console.debug(callee+'.obj:',obj);
    let whash = obj.Hash;
    return whash
}

function ipfsWriteBinary(mfspath,buf) { // truncate doesn't work for version < 0.5 !
    let [callee, caller] = essential.functionNameJS(); // logInfo("message !")
    console.debug(callee+'.inputs:',[{mfspath,buf}]);

    return createParent(mfspath)
	.then(ipfsRmMFSFileUnless06(mfspath))
	.then( _ => {
	    var url = api_url + 'files/write?arg=' + mfspath + '&create=true&truncate=true';
	    return fetchPostBinary(url, buf)
		.then( _ => getMFSFileHash(mfspath)) 
		.catch(console.error)
	})
	.catch(console.warn)
}

function ipfsWriteJson(mfspath,obj) {
    let [callee, caller] = essential.functionNameJS(); // logInfo("message !")
    console.debug(callee+'.inputs:',{mfspath,obj});

    return createParent(mfspath)
	.then(ipfsRmMFSFileUnless06(mfspath))
	.then( _ => {
	    var url = api_url + 'files/write?arg=' + mfspath + '&create=true&truncate=true';
	    return fetchPostJson(url, obj)
		.then( _ => getMFSFileHash(mfspath)) 
		.catch(console.error)
	})
	.catch(console.log)
}

async function makeItRaw(mfspath) {
  let [callee, caller] = essential.functionNameJS(); // logInfo("message !")
  let hash = await getMFSFileHash(mfspath); 
  if (hash == null) {
    return hash;
  }
  console.debug(callee+'.hash:',hash);
  console.debug(callee+'.hash16:',hash.toString(16));
  if (! hash.toString(16).match(/^0155/)) {
   let  url = api_url + 'files/read?arg='+mfspath
   let buf = await fetchRespCatch(url)
   console.debug(callee+'.buf:',buf);
   // remove ?
   url = api_url + 'files/write?arg=' + mfspath + '&raw-leaves=true&trickle=true&cid-base=base58btc&create=true&truncate=true';
   return fetchPostBinary(url, buf)
   .then( _ => getMFSFileHash(mfspath)) 
   .catch(console.error)
  } else {
   return hash;
  }
}

ipfs.ipfsLogMerge = ipfsLogMerge = function ipfsLogMerge(mfspath,log1,log2) {
   let callee = essential.functionNameJS()[0];
   let lines = log1.split('\n');
   let seen = {};
   for (let line of lines) {
     seen[line] += 1;
   }
   for (let line of log2.split('\n')) {
     if (! seen[line]) {
       lines.push(line);
       seen[line] = 1;
     }
   }
   let buf = lines.join('\n') + '\n';
   let url = ipfs.api_url + 'write?file=list.log&parents=true&create=true&raw-leaves=true'
   let form = new FormData(); form.append('file', buf);
   return fetch(url,{method:'POST',mode:'cors',body: form}).then( _ => {
     console.log(callee+'._:',_);
     // TODO: get hash 
   }).catch(console.warn);
}

function ipfsLogAppend(mfspath,record) {
   let [callee, caller] = essential.functionNameJS(); // logInfo("message !")
   console.debug(callee+'.inputs:',[{mfspath,record}]);

   // note is file doesn't exist then 
   return createParent(mfspath)
      .then( _ => { return mfsExists(mfspath); })
      .then( _ => { let [exists,hash] = _ ;
         if (exists) {
         return isRawLeaf(hash)
         .then( isRaw => {
               if (!isRaw) {
               console.info(callee+'.mfspath.isNotRaw:',mfspath);
               return makeItRaw(mfspath);
               } else {
               console.info(callee+'.mfspath.isRaw:',mfspath);
               return true;
               }
               })
         .then( _ => getMFSFileSize(mfspath) )
         .then( offset => { // append file at given offset
               console.debug(mfspath,': offset=',offset);
               let url = api_url + 'files/write?arg=' + mfspath + '&raw-leaves=true&cid-base=base58btc&create=true&truncate=false&offset='+offset;
               return fetchPostText(url, record) // /!\ no "\n" is inserted by default, please add your own if necessary !
               .then( _ => getMFSFileHash(mfspath)) 
               })
         .catch(console.error)
         } else { // create file ...
            let url = api_url + 'files/write?arg=' + mfspath + '&raw-leaves=true&cid-base=base58btc&create=true&truncate=true';
            return fetchPostText(url, record) // /!\ no "\n" is inserted by default, please add your own if necessary !
               .then( _ => getMFSFileHash(mfspath)) 
               .catch(console.error)
         }
       })
       .catch(console.error)

}

async function isRawLeaf(qm) {
    let [callee, caller] = essential.functionNameJS(); // logInfo("message !")
   let url = api_url + 'dag/get?arg='+qm+'&data-encoding=base64';
   let dag = await fetchGetPostJson(url);
   console.debug(callee+'.dag: %s..."}',JSON.stringify(dag).substr(0,36));
   if (typeof(dag.data) == 'undefined') {
      console.debug(callee+'.dag.data (raw-leaf): undefined');
      return true; // is Raw
   } else {
      if (dag.links.length == 0) {
         console.debug(callee+'.dag.links.length (protobuf):',0);
         return false; // there is no links;
      }
      for (let link of dag.links) {
         console.debug(callee+'.link:',link);
         let hash = link.Cid['/']
         console.debug(callee+'.hash:',hash);
         if (! hash.match(/^baf/)) {
           return false;
         }
      }
      return true;
   }
}


function createParent(path) {
    let [callee, caller] = essential.functionNameJS(); // logInfo("message !")
    //console.debug(callee+'.inputs:',{path});

    let dir = path.replace(new RegExp('/[^/]*$'),'');
    var url = api_url + 'files/stat?arg=' + dir + '&size=true'
    return fetch(url, {method:'POST'})
	.then( resp => resp.json() )
	.then( json => {
        if (typeof(json.Code) == 'undefined') {
        console.debug(callee+'.dir:',dir);
        //console.debug(callee+'.json:',json);
        return json;
        } else {
        // {"Message":"file does not exist","Code":0,"Type":"error"}
        console.debug(callee+'.! -e dir',dir);
        console.debug(callee+'.json',json)
        url = api_url + 'files/mkdir?arg=' + dir + '&parents=true'
        return fetch(url,{method:'POST'})
        .then(
              resp => {
              console.debug(callee+'.mkdir.resp:',resp)
              if (resp.ok) { // if mkdir sucessful, return hash
              var url = api_url + 'files/stat?arg=' + dir + '&size=true'
              return fetch(url,{method:'POST'})
              .then( resp => resp.json() )
              } else {
              Promise.reject(new Error(resp.statusText))
              }
              })
        .then ( obj => { console.debug(callee+'.obj: ',obj); return obj })
           .catch(console.error)
        } 
	})
	.catch(console.log)
}

function getMFSFileSize(mfspath) { // size returned by stat depend on integrity of body ...
   let [callee, caller] = essential.functionNameJS(); // logInfo("message !")
   var url = api_url + 'files/stat?arg=' + mfspath + '&size=true'
   console.debug(callee+'.url:',url);
      return fetch(url,{method:'POST'})
      .then( resp => resp.json() )
      .then( json => { return (typeof json.Size == 'undefined') ? 0 : json.Size } )
      .catch(console.log)
}

function ipfsMkdir() {
   let [callee, caller] = essential.functionNameJS(); // logInfo("message !")
   var url = api_url + 'object/new?arg=unixfs-dir';
   return fetch(url,{method:'POST'})
   //  .then( resp => { console.log(callee+'.resp:'); return resp; } )
      .then( resp => resp.json() )
      .then( json => { return json.Hash; })
   .catch(console.error)
}

function mfsRemove(mfspath) {
   var url = api_url + 'files/rm?arg='+mfspath+'&recursive=true';
   return fetch(url,{method:'POST'})
      .then(validateResp)
   .catch(console.error)
}
function mfsCopy(hash,mfspath) {
   let [callee, caller] = essential.functionNameJS(); // logInfo("message !")
   //console.log(callee+'.inputs:',{hash});
   var url = api_url + 'files/cp?arg=/ipfs/'+hash+'&arg='+mfspath;
   console.log(callee+'.url:',url);
   return fetch(url,{method:'POST'})
   .then( resp => resp.text() )
   .then( text => { if (text != '') { console.log(callee+'.text:',text); } return text; })
   .then( _ => { return getMFSFileHash(mfspath); })
   .catch(console.error)


}
function ipfsRemove(name,hash) {
   let [callee, caller] = essential.functionNameJS(); // logInfo("message !")
   var url = api_url + 'object/patch/rm-link?arg='+hash+'&arg='+name
     return fetch(url,{method:'POST'})
     .then( resp => resp.json() )
     .then( json => {
       if (typeof(json.code) == 'undefined' ) {
          return json.Hash;
       } else {
          console.warn(callee+'.error: ! -e %s in qm: ',name,hash); // testing one %s !
          return hash;
       }
     })
   .catch(console.error)
   
}
async function ipfsCopy(mfspath,hash) {
   let [callee, caller] = essential.functionNameJS(); // logInfo("message !")
   let [doesExist,link] = await mfsExists(mfspath);
   //console.log(callee+'.link:',link);
   let name = basename(mfspath);
   //console.log(callee+'.name:',name);
   if (doesExist) {
     var url = ipfs.api_url + 'object/patch/add-link?arg='+hash+'&arg='+name+'&arg='+link;
     console.log(callee+'.url:',url);
     return fetch(url,{method:'POST'})
     .then( resp => resp.json() )
     .then( json => { return json.Hash; })
   .catch(console.error)
   } else {
     console.warn(callee+".mfspath: %s doesn't exist; link: %s",mfspath,link);
     return hash;
   }
}


function ipfsExists(path,qm) {
   let [callee, caller] = essential.functionNameJS(); // logInfo("message !")
   var url = ipfs.api_url + 'files/stat?arg=/ipfs/'+qm+path+'&hash=true';
   return fetch(url,{method:'POST'})
      .then( resp => resp.json() )
      .then( json => {
            // console.log(callee+'.json:',json)
            if (typeof json.Hash == 'undefined') {
              return [false,null]
            } else {
              return [true,json.Hash]
            }
        })
   .catch(console.error)
}

ipfs.mfsExists = mfsExists = function mfsExists(mfspath) {
   let [callee, caller] = essential.functionNameJS(); // logInfo("message !")
   var url = ipfs.api_url + 'files/stat?arg='+mfspath+'&hash=true'
   return fetch(url,{method:'POST'})
      .then( resp => { console.log(callee+'.resp:',resp); return resp; } )
      .then( resp => resp.json() )
      .then( json => {
            if (typeof json.Hash == 'undefined') {
              return [false,null]
            } else {
              return [true,json.Hash]
            }
        })
   .catch(console.error)
}
function mfsLs(mfspath) {
   let [callee, caller] = essential.functionNameJS(); // logInfo("message !")
   var url = api_url + 'files/ls?arg='+mfspath+'&long=true&U=true';
   return fetch(url,{method:'POST'})
      .then( resp => resp.json() )
      .then( json => {
            return json
            })
   .catch(console.error)
}

const mfsGetHashByPath = getMFSFileHash = function (mfspath) {
   let [callee, caller] = essential.functionNameJS(); // logInfo("message !")
   console.debug(callee+'.inputs:',{mfspath});

   var url = ipfs.api_url + 'files/stat?arg='+mfspath+'&hash=true'
      return fetch(url,{method:'POST'})
      .then( resp => resp.json() )
      .then( json => {
            if (typeof(json.Hash) == 'undefined') {
            if (typeof(qmEmpty) != 'undefined') { return qmEmpty }
            else { console.debug(callee+'.json.Hash: undefined'); return qmNull }
            } else {
            return json.Hash
            }
            })
   .catch(console.error)
}
ipfs.mfsGetHashByPath = mfsGetHashByPath;

function fetchAPI(url) {
   let [callee, caller] = essential.functionNameJS(); // logInfo("message !")
   console.debug(callee+'.inputs:',{url});
   return fetch(url,{method:'POST'})
      .then(obj => { return obj; })
      .catch(console.log)
}

 window.ipfs = ipfs;

 return {
  getNid: getNid,
  ipfsGetToken: ipfsGetToken
 };

 // ]
 })();
