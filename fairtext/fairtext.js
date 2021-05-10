// fairtext ...

(function(){
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
   /* build_list(); */
}

function provide_list_log() {
   let promized_peers = provide_peers(); // never end
   return promized_peers;
   // build_history_log(); 
}

async function provide_peers() {
  let token_hash = await provide_list_token('get');
  return find_peers_stream(token_hash);
}

function find_peers_stream(hash) {
  return ipfsFindPeersStream(hash,resolve_peers,display_peers);
}

async function resolve_peers(streamed_objs) {
   let peerids = [];
   if (streamed_objs.length > 0) {
      peers.push(...streamed_objs.filter( (o) => o.Type == 4 ));
      peerids = peers.map((o) => o.Responses[0].ID );
      let refresh_display = false;
      for (p of peerids) {
         if (typeof(p) != 'undefined') {
            console.log('ipfs.ipns_cache[p]:',ipfs.ipns_cache[p]);
            if (typeof(ipfs.ipns_cache[p]) == 'undefined' || 
                       ipfs.ipns_cache[p] != 'pending' &&
                       ! ipfs.ipns_cache[p].match('/ipfs/')) {
                ipfs.ipns_cache[p] = 'pending';
                ipfs.ipfsResolve(`/ipns/${p}/public`).then( ipath => {
                  if (typeof(ipath) != 'undefined') {
                    console.debug('ipns_cache[%s]: %s (updated)',p,ipath)
                    ipfs.ipns_cache[p] = ipath;
                    refresh_display = true;
                  }
                  update_list_log(ipfs.ipns_cache[p],`/logs/${read_reg.list_slug}.log`)
                }).catch(console.warn)
            }
         }
      }
      if (refresh_display) { display_peers(peers); refresh_display = false; }
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
function update_list_log(qmpeer,mfspath) {
  let callee = essential.functionNameJS()[0];
  // TODO ...  get log + append list_slug.log
  console.log(`${callee}.${qmpeer}${mfspath}: need update`)
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
      promised_token_hash = ipfs.ipfsSetToken(token_nid);
    } else {
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


