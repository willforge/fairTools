
(function(){

// GLOBAL DEFINITIONS ...
var fairtext = {}

var i = 0;
const deps = { };

var refresh_display = false;
var log_resolve_promises = []; // keep track of pending promises
// console.log('isoDateTime:',essential.isoDateTime())

// tokens discovery:
const PUBLICID = 'QmezgbyqFCEybpSxCtGNxfRD9uDxC53aNv5PfhB3fGUhJZ';
const editor_token_label = `I have submitted a proposal to ${shortqm(PUBLICID)}`
const editor_token_nid = getNid(`uri:text:${editor_token_label}`);

// Global Registry
const mutables = { 'fetch' : null };
const registry = { };
fairtext.mutables = mutables;
fairtext.registry = registry;
// Read Registry
var read_reg = {
 list_label: null,
};
// IRP registry (old)
var irp_reg = {
};

// events :
const useCapture = true; // capture, bubbling: false
let elem = document.getElementsByName('list_label')[0];
elem.addEventListener('change', read_list_label,useCapture);

elem = document.getElementsByName('fetch')[0];
elem.addEventListener('click', irp_pull,useCapture);

irp_pull({target:{name:'fetch'}});

// --------------------------------------------------------
// main :
   provide_list_token().then(token => { 
     let el = document.getElementById('list_token');
     el.innerText = token;
   }).catch(console.warn);

// --------------------------------------------------------

function pull(ev) {
   let callee = essential.functionNameJS()[0];
   provide_list_log(callee)
   .then(load_sorted_list);

   // TODO: periodically refresh peers list
   /* build_list(); */
}

function irp_pull(ev) { // "main" (fetch button has been click!)
  let caller = ev.target.name // input name (button)
  let callee = essential.functionNameJS()[0];
  console.debug('caller,callee:',caller,callee);
  dag_build(caller,callee)

  const promise = provide_sorted_list(callee);
  promise.then(display_dot);
  promise.then(display_sorted_list);
  return promise;
}

function display_dot() {
  console.log('display_dot.deps:',deps);
} 

function provide_sorted_list() { // sorted by median
  let callee = essential.functionNameJS()[0];
  const promized_text_metadata = provide(callee,'text_metadata',provide_text_metadata);

  return build(callee,'sorted_list',build_sorted_list,[promized_text_metadata]);
}

function provide_list_text() {
  const promized_list_log = provide(callee,'list_log',provide_list_log);
  console.debug(callee+'.promized_list_log:',promized_list_log);
}

function provide_text_metadata() {
  let callee = essential.functionNameJS()[0];

  const promized_scores = provide(callee,'scores',provide_scores)
  console.debug(callee+'.promized_scores:',promized_scores);

  let promized_medians = build(callee,'medians',compute_medians,[promized_scores]);
   console.log(callee+'.promized_medians:',promized_medians);

  // build ...
  return build(callee,'text_metadata',build_text_metadata,
          [promized_scores,promized_medians]);
}


function provide_scores() {
  let callee = essential.functionNameJS()[0];
  const promized_list_text = provide(callee,'list_text',provide_list_text)

  return build(callee,'scores',build_scores,[promized_list_text]);
}

function build_text_metadata() {
   return null;
}

function build_scores(list_text) {
  let scores = {};
  return scores;
}
function provide_list_text() {
  let callee = essential.functionNameJS()[0];
  //       const promized_list_log = provide(callee,'list_log',provide_list_log);
  let list_text = ['text1','text2'];
  return Promise.resolve(list_text);
}

function compute_medians() {
  return { text1: 12, text2: 4 }
}

function build(parent,name,compute,proms) {
   return Promise.all(proms).then( results => {
     let value = compute(results);
     console.log(parent+'.build.'+name+':',value);
     return value;
   })
}

function display_sorted_list(list) {
 let el = document.getElementById('list');
 let buf = '<ul>';
 for (let text of list) {
   let [ts,qmhash,author,textid,path] = text;
   ts = parseInt(ts.slice(0,-1)); // remove trailing ':'
   //console.log('ts:',ts);
   let [date,time] = essential.isoDateTime(ts);
   buf += `<li>${textid}: <a href="${ipfs.gw_url}/ipfs/${qmhash}">${qmhash}</a>`+
           ` ${author} <a>${path}</a> (${date} @${time})</li>`;
 }
 buf += '</ul>'
 
 el.innerHTML = 'list: '+buf;
}

const uniquify_n_split = function(buf) { // uniquify before write
  let callee = essential.functionNameJS()[0];
   let seen = {};
   let uniq = [];
   buf = buf.replace(/\r/g,'');
   // buf = buf.replace(']',']\n') // Why ??? 
   console.log(callee+'.buf:',buf);
      let lines = buf.slice(0,-1).split('\n'); // might have \r\n !
   console.log(callee+'.lines:',lines);
   for (let line of lines) {
      if ('undefined' == typeof(seen[line])) {
         seen[line] = 1;
         let rec = line.split(' ');
         rec[0] = rec[0].slice(0,-1); // chomp (remove ':')
         uniq.push(rec)
      }
   }
   return uniq
}


function build_sorted_list(list_log) {
  let callee = essential.functionNameJS()[0];
  let unsorted_list = list_log.split('\n').slice(0,-1);
  console.log(callee+'.unsorted_list:',{'list':unsorted_list});
  let lines = unsorted_list.sort().reverse(); // reverse alphabetic
   let list_texts = [];
   for (let line of lines) {
     if (line.match(/^\D+/)) { continue; } // skip non-timestamped lines
     let fields = line.split(' ');
     list_texts.push(fields);
   }
   console.log(callee+'.list_texts:',list_texts);
   return list_texts;

  // console.log(callee+'.records:',records);
  // return records;
}

function by_stamp(a,b) {
 return a[0] - b[0];
}
function by_first_key(a,b) {
 // sort by increasing key;
 return compare(a[0],b[0]);
}

function provide(caller,name,provide_n_build) {
  let callee = essential.functionNameJS()[0];
  dag_build(caller,name);
  if (isValid(name)) { return getRegistry(name) } else { setRegistry(name,null,null); }
  return provide_n_build().then( value => {
        let newkey= hash(value);
        if (hasChanged(name,newkey)) {
          invalidate(caller);
          setRegistry(name,newkey,value);
        }
        return value;
        })
}

function getRegistry(name) {
  let key = mutables[name];
  return registry[key];
}
function setRegistry(name, key, value) {
  mutables[name] = key; 
  registry[key] = value;
}

function hash(anything) {
  let callee = essential.functionNameJS()[0];
  // /!\ value need to be a string (can be a serialized json)
  if (typeof(anything) != 'string') {
    console.warn(callee+'.typeof(anything):',typeof(anything))
    anything = JSON.stringify(anything)
  }
  let len = anything.length;
  return sha1(`blob ${len}\0`+anything);
}

function provide_list_log() {
  let callee = essential.functionNameJS()[0];
   //let promized_list_log = await provide_local_list_log(); 
   let promized_logs = provide_peers() // ? never end
    .then(update_list_log)

   promized_logs.then(result => {
     console.debug(callee+'.promized_logs.return:',result);
   })
   return promized_logs;
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
         return Promise.allSettled(log_resolve_promises)
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
                if (false) {
                   ipfs.ipfsPeerConnect(p,undefined).then( proms => { // (1) undefined means any layers are ok
                         console.log('ipfsPeerConnect.then:',proms);
                         let el = document.getElementById('console');
                         el.innerText = JSON.stringify(proms);
                         });
                }
                let promise = ipfs.ipfsResolve(`/ipns/${p}/public`).then( ipath => { // (2)
                  if (typeof(ipath) != 'undefined') {
                    console.log('%s.ipath:',shortqm(p),ipath);
                    console.debug('ipns_cache[%s]: %s (updated)',p,ipath)
                    ipfs.ipns_cache[p] = ipath;
                    refresh_display = true;
                    return Promise.resolve('ipfsResolve failed for: '+p);
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
    let promized_write = ipfs.ipfsWriteContent(local_logf,logs,{ raw: true })
    .then( hash => { console.debug(callee+'.logs.hash:', hash); return hash; })
    .then( hash => {
       let auto_publish = document.getElementsByName('publish')[0].checked;
       if (auto_publish) {
        ipfs.ipfsPublishByPath('/public'); // systematic publish
       } else {
        console.info(callee+'.skip.publish');
       }
       return hash;
    })
    return logs;
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


function invalidate(parent,indent) {
  const key = parent.replace('provide','');
  if ('undefined' == typeof indent) { indent = 0 };
  spaces = '................................................'.substr(0,indent);
  registry[key] = null;
  console.debug(spaces+'invalidate.registry.%s: invalidated', key);
  if (typeof deps[parent] != 'undefined') {
     for (let node of deps[parent]) {
        console.debug(spaces+'invalidate.deps.node:', node);
        invalidate(node,indent+1);
     }
  }
  return null;
 }

 function isValid(name) {
   return (typeof(mutables[name]) != 'undefined' && registry[name] != null);
 }
 function hasChanged(name,hash) {
  let key = mutables[name];
  if ('undefined' != typeof registry[key]) { return true; }
  return (hash != registry[key]);
 }

 // build Deps Acyclic Graph ...
 function dag_build(parent,name) {
   console.log('dag_build:',deps);
   if (typeof(deps[name])) {
    deps[name] = [];
   }
   deps[name].push(parent);
   return deps;
 }


/* /!\ PLEASE DO NOT PUT ANY CODE BELOW THIS LINE */

window.fairtext = fairtext;
return fairtext;

})();
