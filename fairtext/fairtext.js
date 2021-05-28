// fairtext ...

(function(){

var i = 0;
var refresh_display = false;
var log_resolve_promises = []; // keep track of pending promises
// console.log('isoDateTime:',essential.isoDateTime())

// GLOBAL DEFINITIONS ...
var fairtext = {}
// tokens discovery:
const PUBLICID = 'QmezgbyqFCEybpSxCtGNxfRD9uDxC53aNv5PfhB3fGUhJZ';
const editor_token_label = `I have submitted a proposal to ${shortqm(PUBLICID)}`
const editor_token_nid = getNid(`uri:text:${editor_token_label}`);

// Read Registry
var read_reg = {
 list_label: null,
};
// IRP registry
var irp_reg = {
};

// events :
const useCapture = true; // capture, bubbling: false
let elem = document.getElementsByName('list_label')[0];
elem.addEventListener('change', read_list_label,useCapture);

elem = document.getElementsByName('fetch')[0];
elem.addEventListener('click', fetch,useCapture);

// --------------------------------------------------------
// main :
   provide_list_token().then(token => { 
     let el = document.getElementById('list_token');
     el.innerText = token;
   }).catch(console.warn);

// --------------------------------------------------------

function fetch(ev) {
   provide_list_log();
   // TODO: periodically refresh peers list
   /* build_list(); */
}

function provide_list_log() {
   //let promized_list_log = await provide_local_list_log(); 
   let promized_peers = provide_peers(); // never end


   return promized_peers;
   // build_history_log(); 
}

async function provide_peers() {
  let token_hash = await provide_list_token(); // 2nd set !
  return find_peers_stream(token_hash);
}

function find_peers_stream(hash) {
  log_resolve_promises = []; // keep track of pending promises
  return ipfsFindPeersStream(hash,resolve_peers,display_peers)
  .finally( _ => {
      if (log_resolve_promises.length > 0) {
         Promise.allSettled(log_resolve_promises).then(update_list_log)
      }
  });
}

async function resolve_peers(streamed_objs) {
   let newpeers = [];
   let peerids =[] // peerids of arriving newpeers
   let offset = peers.length - 1 ;
   if (streamed_objs.length > 0) {
      newpeers.push(...streamed_objs.filter( (o) => o.Type == 4 ));
      peerids = newpeers.map((o) => { return {id: o.Responses[0].ID}; } );
      if (peerids.length > 0) {
        console.info('stream#%s %s peers: %o',i++,peerids.length,peerids);
      }
      for (let pi in newpeers) {
         let np = newpeers[pi];
         let p = np.Responses[0].ID;
         if (typeof(p) != 'undefined') {
            console.log('ipfs.ipns_cache[%s]:',shortqm(p),ipfs.ipns_cache[p]);
            if (typeof(ipfs.ipns_cache[p]) == 'undefined' || 
                       ipfs.ipns_cache[p] != 'pending' &&
                       ! ipfs.ipns_cache[p].match('/ipfs/')) {
                ipfs.ipns_cache[p] = 'pending';
                ipfs.ipfsPeerConnect(p,undefined).then( proms => { // (1) undefined means any layers are ok
                  console.log('ipfsPeerConnect.then:',proms);
                  let el = document.getElementById('console');
                  el.innerText = JSON.stringify(proms);
                });
                let promise = ipfs.ipfsResolve(`/ipns/${p}/public`).then( ipath => { // (2)
                  if (typeof(ipath) != 'undefined') {
                    console.log('%s.ipath:',shortqm(p),ipath);
                    console.debug('ipns_cache[%s]: %s (updated)',p,ipath)
                    ipfs.ipns_cache[p] = ipath;
                    refresh_display = true;
                    return Promise.resolve(p);
                  } else {
                    console.log('%s.ipath:',shortqm(p),ipath);
                    if (ipfs.ipns_cache[p] == 'pending') {
                      ipfs.ipns_cache[p] = undefined;
                    }
                    return Promise.reject(p); // !!!!! ???
                  }
                }).catch(console.error)
                log_resolve_promises.push(promise) // <--
            }
         }
      }
      // Promise.any().then();
      peers.push(...newpeers); // append newpeers to global list of peers
      if (refresh_display) {
         console.log('%s #peers:',i,peers.length);
         display_peers(peers); refresh_display = false;
      }
   }
   return peerids;
}

function display_peers(peers) {
  console.log('display.peers:',peers);
  let peerids = peers.map(p => p.Responses[0].ID)
  let el = document.getElementById('peerlist');
  let ul = '<li>';
  ul += peerids.map(p => { return ipfs.shortqm(p);}).join('\n</li><li>');
  ul += '</li>\n';
  el.innerHTML = ul
}
function update_list_log(proms) {
  let callee = essential.functionNameJS()[0];
  let slug = read_reg.list_slug;
  let logpath = `/logs/${slug}.log`;
  console.log(callee+'.proms:', proms);

  let local_logf = '/public' + logpath
  return mfsExists(local_logf).then( _ => {
  if (_[0]) {
    return ipfs.mfsGetContentByPath(local_logf);
  } else {
 
    let [date,time] = essential.isoDateTime()
    let buf = `# ${slug}.log from ${ipfs.peerid} on ${date} at ${time}\n`;

    return buf;
  }

  }).then(logs => {
  let remote_promises = [];

  for (let pi in proms) {
   let peerid = proms[pi].value
   let qmpeer = ipfs.ipns_cache[peerid]
   if (proms[pi].status == 'rejected' ) {
    console.log(callee+'.proms[%s]: %o (rejected)',pi,proms[pi]);
    continue;
   } else {
    console.log(callee+'.proms[%s]: %o (ipns -> %s)',pi,proms[pi],qmpeer);
   }


  let remote_logf = qmpeer + logpath
  console.log(`${callee} ${peerid} ${qmpeer}${logpath}`)

  let promise = ipfs.ipfsGetContentByPath(remote_logf)
    .then(buf => [peerid,buf]);
  remote_promises.push(promise)
  }
  return Promise.all(remote_promises).then( results => {
    for (let result of results) {
      let buf = result[1]
      logs += buf; // assume this operation is atomic (i.e. 1 JS thread)
      console.log(callee+'.promise.all.buf[%s]:',ipfs.shortqm(result[0]),{'lines': buf.split('\n')})
    }
    // uniquify:
    logs = uniquify(logs);
    console.log('logs:',{'lines': logs.split('\n')})
    return ipfs.ipfsWriteContent(local_logf,logs,{ raw: true })
    .then( hash => { console.debug(callee+'.logs.hash:', hash); return hash; })
    .then( hash => { ipfs.ipfsPublishByPath('/public'); })
  })
  

}).catch(console.error);

}

function uniquify(buf) {
  let lines = buf.replace(/\r/g,'').slice(0,-1).split('\n');
  let seen = {'':null}; // to skip all empty lines
  let uniq = '';
  for (let rec of lines) {
    rec = correct_ts(rec);
    if (typeof seen[rec] == 'undefined') {
      uniq += rec+'\n';
      seen[rec] = 1;
    } else {
      seen[rec]++;
    }
  }
  return uniq;
}

function correct_ts(rec) { // QmPhpQ8DUiyKqrFiginKeiHbF3w1ARGwkj6s8jkQGgTEX8
   let fields = rec.split(' ');
   let ts = fields[0].slice(0,-1);
   if ( rec.match(/^#/) ) { return rec; }
   if ( rec.match(/^NaN:/) ) { return rec.replace('NaN:','#'); }
   if (rec.match(/^\D/) ) {
      rec = ''; // remove line
      console.log('correct_ts: remove record:',ts);
   } else if (ts.length < 11) {
      console.log('correct_ts:',ts);
      let stamp = parseInt(ts) * 1000;
      fields[0] = stamp + ':'
      rec = fields.join(' ')
   }
  return rec;
}


function read_list_label() {
  let elem = document.getElementsByName('list_label')[0];
  let slug = essential.slugify(elem.value);
         read_reg.list_label = elem.value || 'Fair List';
  return read_reg.list_slug = slug || 'fair-list';
}

function provide_list_token() {

  if ( typeof read_reg.list_label == 'undefined' ||
              read_reg.list_label == null) { read_list_label(); }
  console.log('provide_list_token.list_slug:',read_reg.list_slug)

  let statement = `I have submitted a proposal to ${shortqm(PUBLICID)} for ${read_reg.list_label}`
  let token_nid = ipfs.getNid(`uri:tree:${statement}`)

  return ipfs.mfsExists(`/public/logs/${read_reg.list_slug}.log`).then( _ => {
    let promised_token_hash;
    if (_[0]) { // list_slug.log exists
      console.log('provide_list_token.setToken:',token_nid)
      promised_token_hash = ipfs.ipfsSetToken(token_nid);
      promised_announce = ipfs.ipfsProvideHash(promised_token_hash);
    } else {
      console.log('provide_list_token.GetToken:',token_nid)
      promised_token_hash = ipfs.ipfsGetToken(token_nid);
    }
    return promised_token_hash.then(
     hash => {
      irp_reg.list_token = hash;
      console.log('provide_list_token.hash:',hash);
      // TODO: invalidate  list_token,list_label,list_slig in upstream 
      return hash; }
     ); // all provides are promises
  })
  .catch(console.warn);
}

window.fairtext = fairtext;
return fairtext;
})();


