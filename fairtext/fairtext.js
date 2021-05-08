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
  let token_hash = await provide_list_token();
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
            if (typeof(ipfs.ipns_cache[p]) == 'undefined') {
                refresh_display = true;
                ipfs.ipns_cache[p] = 'pending';
                ipfs.ipfsResolve(`/ipns/${p}/public`).then( qm => {
                  if (typeof(qm) != 'undefined') {
                    console.debug('ipns_cache[%s]: %s (updated)',p,qm)
                    ipfs.ipns_cache[p] = qm;
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
  return read_reg.list_slub = slug || 'fair-list';
}

function provide_list_token() {
  if ( typeof read_reg.list_label == 'undefined' || read_reg.list_label == null) { read_list_label(); }
  let statement = `I have submitted a proposal to ${shortqm(PUBLICID)} for ${read_reg.list_label}`
  let token_nid = ipfs.getNid(`uri:tree:${statement}`)
  let promised_token_hash = ipfs.ipfsGetToken(token_nid);
  return promised_token_hash.then(
     hash => {
      irp_reg.list_token = hash;
      console.log('provide_list_token.hash:',hash);
      // TODO: invalidate  list_token,list_label,list_slig in upstream 
      return hash; }
   ); // all provides are promises
}

window.fairtext = fairtext;
return fairtext;
})();

