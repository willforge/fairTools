const dbug = 1;
var forest = {};
const qmipns = '/ipfs/QmTc2ZGJfPUocFXQ9euS9X7uHjW1CovasHTZGrUW4KPo8Y';
const qmempty = 'QmbFMke1KXqnYyBBWxB74N4c5SBnJMVAiMNRcGu6x1AwQH';
const qmwebui='Qmb3cY3zFJ5isjJ5H9cP47Vfqa6pqNwypbuo2TiBGjUmLd';

// globals :
var list_label = 'Fair List';
var list_labelp = 'fair-list';
var peerid;
var peerids = [];
var rankers = [];
var score_db = {};
var score_lock = false;
var history_lock = false;


let score = document.getElementsByName('score')[0].value;
var node_json = {};

function display_score(ev) {
 let value = ev.target.value;
 document.getElementsByName('score')[0].value= value;
}
function update_value(ev) {
 let value = ev.target.value;
 document.getElementsByName('value')[0].value= value;
}


var sn=0;
var rank = [];
var global_db = {}; // global database that holds all the votes for all the texts w/ their metadata (200 x 10M records !!!)

// -----------------------------------------------------------------------------
/// GLOBAL DEFINITONS ...
// TODO have a registry to obtain public's private-key
const PUBLICID = 'QmezgbyqFCEybpSxCtGNxfRD9uDxC53aNv5PfhB3fGUhJZ';
const editor_token_label = `I have submitted a proposal to ${shortqm(PUBLICID)}`;
const editor_token_nid = getNid(`uri:text:${editor_token_label}`);
let promise = update_token_hash('editor_token_hash',editor_token_nid);
document.getElementById('editor_token_nid').innerHTML=editor_token_nid;

var list_token_label = editor_token_label + ' for ' + list_label;
var list_token_nid;
update_label({});

var rankers_token_hash; 
// -----------------------------------------------------------------------------

function slugify(s) {
 let slug =  s.toLowerCase().replace(/[^a-z0-9]+/g,'-');
 return slug;
}

function update_label(ev) {
  let label = document.getElementsByName('list_label')[0].value;
  if (typeof(label) != 'undefined' && label != '') {
    list_label = label;
    list_labelp = slugify(list_label)
    list_token_label = editor_token_label + ' for ' + list_label;

  }
  console.log('update_label.list_labelp:', list_labelp);
  list_token_nid = getNid(`uri:tree:${list_token_label}`);
  let promise = update_token_hash('list_token_hash',list_token_nid);
  document.getElementById('list_token_label').innerHTML=list_token_label;
  document.getElementById('list_token_nid').innerHTML=list_token_nid;
  document.getElementsByName('label')[0].value = list_label;

}
async function update_token_hash(token_hash_id,nid) {
  let [callee, caller] = functionNameJS(); // logInfo("message !")
  let token_hash = await ipfsGetToken(nid);
  console.debug(callee+'.token_hash:',token_hash);
  document.getElementById(token_hash_id).innerHTML=token_hash;
}

function update_qmhash_value(ev) {
  let qmselect = document.getElementsByName('qmhash')[0];
  let qmhash = ev.target.value;
  qmselect.options[0].value = qmhash;
  qmselect.options[0].text = `as above: ${shortqm(qmhash)}`;
  return qmhash
} 
function update_qmhash(ev) { // build DOM html select list, node's payload, and return json
  let [callee, caller] = functionNameJS(); // logInfo("message !")
  let qmhash = document.getElementsByName('qmhash')[0].value;
  let node_urn = getNid(`uri:ipfs:${qmhash}`);
  console.log(callee+'.qmhash:',qmhash);
  document.getElementById('qmhash').innerHTML = `<a target="_new" href=${gw_url}/ipfs/${qmhash}>${qmhash}</a>`;
  document.getElementById('node_hash').innerHTML = qmhash;
  document.getElementsByName('node_urn')[0].value = node_urn;
  let node_urn_elements = document.getElementsByClassName('node_urn');
  for (node_urn_element of node_urn_elements) {
     if (typeof(node_urn_element.template) == 'undefined') {
        node_urn_element.template = { 'href':undefined,'info':undefined};
        console.log(callee+'.node_urn_element.template:',node_url_element.template);
     }
     if (typeof(node_urn_element.template.link) == 'undefined') {
        console.log(callee+'.node_urn_element.href:',node_urn_element.href);
        node_urn_element.template.link = node_urn_element.href;
        console.log(callee+'.node_urn_element.template.link:',node_urn_element.template.link);
     }
     if (typeof(node_urn_element.template.info) == 'undefined') {
        node_urn_element.template.info = node_urn_element.innerHTML;
     }
     node_urn_element.href = node_urn_element.template.link.replace(':node_urn',node_urn);
     node_urn_element.innerHTML = node_urn_element.template.info.replace(':node_urn',node_urn);
  }
  document.getElementsByName('node_urn')[0].value = node_urn;
  //update_root_hash();  {/... /etc /my /public} saved in /.../published

  let promise_text = ipfsGetContentByHash(qmhash)
  .then( text => {
     console.log(callee+'.text:',text);
     document.getElementById('selected_text').innerHTML = text;
     return text;
  })
  .catch(console.error)
  
  // lookup (local) median for the text qmhash ...
  let promised_qmjson = get_qmjson(qmhash)
  .then( async (qmjson) => {
    console.log(callee+'.qmjson:',qmjson);
    if (typeof(qmjson) != 'undefined') {
      let buf = await ipfsGetContentByHash(qmjson); // /!\ return a json if not a text 
      if (typeof(buf.median) != 'undefined') {
        node_json = buf;
      } else {
        return 'Qmajqtcsfew6yqbC2cB4A1gJEwH5SzpxRgrhKyxsugXxZb'; // {'median': -1 };
      }
      document.getElementById('survey').innerHTML = `<a target="_new" href=${gw_url}/ipfs/${qmjson}>${node_json.median}</a>`;
      document.getElementById('nbv').innerHTML = node_json.n;
      return qmjson;
    } else {
      return 'QmfNus1rPpKRdyHPUqY18z5MRUQPkWP7drGqszXTNUXMCU'; // {'median': -2 };
    }
  })
  .catch(console.error)

  return promised_qmjson;
}

async function find_rankers(ev) {
      let qmhash = document.getElementsByName('qmhash')[0].value;
      return get_rankers_by_qm(qmhash);
}


async function history_pull(ev) {
   let [callee, caller] = functionNameJS(); // logInfo("message !")
   let qmhash = document.getElementsByName('qmhash')[0].value;
   let node_urn = getNid(`uri:ipfs:${qmhash}`);
   if (typeof(global_db[node_urn]) == 'undefined') { global_db[node_urn] = {} }
   let historyf = `/public/logs/${node_urn}-history.log`;
   document.getElementById('history_status').innerHTML='<font color=orange>busy</font>';

   let promised_trigger_histories = [];
   if (rankers.length > 1) {
   for (let ranker of rankers) {
      let checked = document.getElementsByName('x'+ranker)[0].checked;
      if (! checked) { console.info(callee+'.ranker.skipped:',ranker); continue; }

      document.getElementById('x'+ranker+'_ipns_status').innerHTML = '<img src="../img/spinner.gif" height="24">';
      if (ranker != peerid) {
        let promisedPing = ipfsPing(ranker);
      }
      cb = function(p) {
         console.debug(callee+'.cb.p:',p);
         document.getElementById('x'+ranker+'_ipns_status').innerHTML = `<img title="${p}" src="../img/check-mark.png" height="24">`;
      };
      document.getElementById('ipns_status').innerHTML = '<img src="../img/spinner.gif" height="24">';
      let ranker_path = await ipfsNameResolve(ranker,cb);
      document.getElementById('ipns_status').innerHTML = '<img src="../img/check-mark.png" height="24">';
      // if (! await mfsSilentExists(`${ranker_path}${historyf}`)) { continue; }
      let promised_histo = ipfsGetContentByPath(`${ranker_path}${historyf}`)
      .then(hist => { return trigger_history_concat(node_urn,hist); })
      .catch(console.log);
      promised_trigger_histories.push(promised_histo);
   }
   Promise.all(promised_trigger_histories)
   .then( _ => { 
      let history_db = global_db[node_urn];
      return map_db_write(historyf,history_db) // replace *-history.log w/ history_db
      .then( qm => {
        document.getElementById('history_status').innerHTML = `<img title="${qm}" src="../img/check-mark.png" height="24">`;
        document.getElementById('qmhistory').innerHTML = `<a href="${gw_url}/ipfs/${qm}">${qm}</a>`;
        return qm;
      })
      .catch(console.error);
   })
   .catch(err => { console.trace(callee+'.err:',err); return err; })
   .finally( qm => { console.trace(callee+'.qm: %s for %s',qm,node_urn); return score_db_update(node_urn); });
   } else {
     console.info(callee+'.rankers.length:',rankers.length);
   }
}

function score_db_update(node_urn) {
  let [callee, caller] = functionNameJS(); // logInfo("message !")
  console.trace(callee+'.node_urn:',node_urn)
  let history_db = global_db[node_urn]
  console.log(callee+'.history_db:',history_db)
  sorted_keys =  Object.keys(history_db).sort(alphabetically)
  console.log(callee+'.sorted_keys:',sorted_keys)

  let onevote = {}; // garantee vote unicity ( 1 peer == 1 vote )
  for (let key of sorted_keys) {
    /* old format ... *
    let [ts,peer] = key.split(',');
    onevote[peer] = [ts,...history_db[key]];
    console.log(callee+'.onevote[%s]=%o ts:%s',peer.substr(-4),history_db[key],ts)
    */
    let op = history_db[key][1];
    let peer = history_db[key][2];
    if (op === 'A') {
      onevote[peer] = history_db[key]; // overwrite previous grades and keep the last one
    } else if (op === 'M') {
        console.log(callee+'.median:',median);
    } else {
      console.log(callee+'.history_db[%s]: %s (skipped)',key,history_db[key]);
    }
  }
  console.log(callee+'.onevote:',onevote);

  // reset scores ... {compute from scratch}
  score_db.tic = Date.now();
  score_db.n = 0;
  score_db.score = {}
  // mymap.forEach( (k,v) => { console.log(callee+'.peer:',k); });

  for (let key of Object.keys(onevote)) {
      let [ts,op,peer,grade,median] = onevote[key];
      if (op === 'A') {
        score_db.n += 1
        if (typeof(score_db.score[grade]) == 'undefined') {
           score_db.score[grade] = [ts,1,peer]; // create a new record !
        } else {
           score_db.score[grade][0] = ts // time at which the vote is casted
           score_db.score[grade][1] += 1 // weight of the voted score
           score_db.score[grade][2] = peer // peerkey who voted last
       }
      }
  }
  console.log(callee+'.score_db.score:',score_db.score);
  median = compute_median(score_db,0.5);
  score_db.median = median;
  console.log(callee+'.score_db:',score_db)
  console.info(callee+'.median:',median)
  console.info(callee+'.score_db.n:',score_db.n)

  document.getElementById('median').innerHTML = score_db.median;
  document.getElementById('nbp').innerHTML = score_db.n;

  // leave a record in history_db
  let promised_qmjson = get_qmjson_by_urn(node_urn)
     .then( qmjson => {
           // add history trail
           let ts = Date.now(); // timestamp
           let qmhash = document.getElementsByName('qmhash')[0].value;
           let key = `${ts}:${shortqm(peerid)}`;
           let op = 'M'; // flag record w/ median tag
           let record = `${key} ${ts} ${op} ${peerid} - ${median}`; /// !!!
           // paper-trail (auditable) published under fixed label path
           let promised_qmhistory = history_append(ts,qmhash,qmjson,record);
     })
     .catch(console.error);

  return score_db;
}

function trigger_history_concat(node_urn,hist) {
  let [callee, caller] = functionNameJS(); // logInfo("message !")
   if (typeof(hist.Code) == 'undefined') {
      /* console.log(callee+'.hist:',hist.substr(0,76)+'...'); */
      return new Promise(function(resolve,reject) {
         var event = setInterval(function() {
             if (! history_lock ) {
               history_lock = true;
               display_status('history_lock','locked');
               console.log(callee+'.hist:',hist);
               resolve(hist);
               history_lock = false;
               display_status('history_lock','unlocked');
               clearInterval(event);  
             } else { 
               console.log(callee+'.history_lock:',history_lock);
             }
         },1000)
         // no reject: wait indefinetly ...
         
      }).then(hist => {
        if ( ! history_concat(node_urn,hist) ) { history_lock = false; console.log('history_lock: abort') }
        /*
        try { if ( ! history_concat(hist) ) { throw "failed merge" }; }
        catch(err) { history_lock = false }
         */
         return true;
      }).catch(console.error);
   } else {
     console.trace(callee+'.hist:',hist);
     return Promise.resolve(false);
   }
}


function history_concat(node_urn,hist) {
  let [callee, caller] = functionNameJS(); // logInfo("message !")

  if (hist.match(/\r/)) { hist = hist.replace(/\r/g,''); }
  let lines = hist.slice(0,-1).split(/\n/);
  for (let line of lines) {
    if (line.match(/^#/)) { continue; }
    console.log(callee+'.line: "%s"',line);
    
    let fields = line.split(' ');
    let uniq_key,ts,op,peer,grade,median;
    console.debug(callee+'.fields:',fields);
    /* -------------------------------------------- */
    // format migration !
    if (fields.length <= 5) { // old format
      console.warn(callee+'.hist: is in old format');
      let key;
      [ key,op,peer,grade,median ] = fields;
      uniq_key = `${key},${peer}`;
      ts = key;
      if (grade.match(',')) { [grade,median] = grade.split(','); } // format migration
    } else { // new format 6 elements
      [ uniq_key,ts,op,peer,grade,median ] = fields;
    }
    /* -------------------------------------------- */
    uniq_key = ts + ':' + shortqm(peer);
    console.debug(callee+'.uniq_key: %s',uniq_key);

    if (typeof(grade) != 'undefined') {
       if (typeof(global_db[node_urn]) == 'undefined') { global_db[node_urn] = {} } // should be already initialized ...
       let history_db = global_db[node_urn];
       if (typeof(history_db[uniq_key]) == 'undefined') {
         console.debug(callee+".history_db[%s]: %s (i.e. not seen)",uniq_key,history_db[uniq_key] );
         history_db[uniq_key] = [ts,op,peer,grade,median];
       } else { // ?
         console.warn(callee+".warning: duplicate  ... w/:",grade,uniq_key );
         console.warn(callee+".history_db[%s]: %s",uniq_key,history_db[uniq_key] );
         // throw " seen !";
       }
       global_db[node_urn] = history_db;
    }
  }
  return true;
}

function alphabetically(a,b) {
  /* return -1; // -1 as is ; 1 ack as a reverse; */
  return ( a > b ) ? 1 : (a < b) ? -1 : 0; // alphabetic !
}
function numerically(a,b) {
 return a-b ; // numerical sort !
}

async function survey_pull(ev) { // collect and merge all json files 

   let qm = document.getElementsByName('qmhash')[0].value;
   let node_urn = getNid(`uri:ipfs:${qm}`);

   // get score providers (rankers)
   let peers = await get_rankers_by_qm(qm);
   let randomized_rankers = peers.sort(randomly);
   //let logsf = `/public/logs/${node_urn}-history.log`;
   //let promized_logs = [];
   for (let ranker of randomized_rankers) {
      document.getElementById('ipns_status').innerHTML = '<img src="../img/spinner.gif" height="24">';
      let ranker_path= await ipfsNameResolve(ranker);
      document.getElementById('ipns_status').innerHTML = '<img src="../img/check-mark.png" height="24">';
      let score_jsonf = `/public/logs/${node_urn}-state.json`;
      let promised_json = ipfsGetJsonByPath(`${ranker_path}${score_jsonf}`)
      .then(trigger_score_update)
      .catch(console.log);
   }
}

function trigger_score_update(json) {
  let [callee, caller] = functionNameJS(); // logInfo("message !")
   if (typeof(json) != 'undefined') {
      console.log(callee+'.ranker:',json.peerid);
      var event = setInterval(function() {
         if (! score_lock ) {
            score_lock = true;
            display_status('score_lock','locked');
            //console.log(callee+'.json:',json);
            update_score_db(json);
            score_lock = false;
            display_status('score_lock','unlocked');
            clearInterval(event);  
         } else {
           console.log(callee+'.score_lock:',score_lock);
         }
      }, 100);
   }
  return score_lock;
}
function max(a,b) {
  if (a > b) { return a; } else { return b };
}

async function update_score_db(remote_score) {
  let [callee, caller] = functionNameJS(); // logInfo("message !")
  console.log(callee+'.ranker_score.peerid:',remote_score.peerid);
  console.log(callee+'.remote_score:',remote_score);
  if (typeof(score_db.score) == 'undefined') {
    score_db = remote_score;
  } else {
     let new_n = 0
     for (let grade of Object.keys(score_db.score)) {
        //           0        1           2
        let [remote_ts,remote_w,remote_peer] = remote_score.score[grade]; // ipns ... TODO error is grade don't exists
        let [local_ts,local_w,local_peer] = score_db.score[grade]; // mfs

        if (remote_w > local_w) {
           score_db.n += remote_w - local_w;
           score_db.score[grade][1] = remote_w;
           console.log(callee+'.grade:',grade,'weight:',remote_w);
           // update other fields
           score_db.score[grade][0] = remote_ts;
           score_db.score[grade][2] = remote_peer;
           if (typeof(remote_score.qmtext) != 'undefined') {
             score_db.score.qmtext = remote_score.qmtext;
           }
        }
        new_n += score_db.score[grade][1];
     }
     // recompute median :
     median = compute_median(score_db,0.5);
     score_db.median = median;
    
     console.log(callee+'.n:',score_db.n)
     console.log(callee+'.new_n:',new_n)
     score_db.n = new_n;
  }
  document.getElementById('survey').innerHTML = score_db.median;
  document.getElementById('nbv').innerHTML = score_db.n;
  let node_urn = getNid(`uri:ipfs:${score_db.qmtext}`);
  let score_resultf = `/public/share/${node_urn}-result.json`;
  let promised_qmresult = await ipfsWriteJson(score_resultf,score_db)
  .then( qm => {
      document.getElementById('qmresult').innerHTML = `<a href="${gw_url}/ipfs/${qm}">${qm}</a>`;
      console.log(callee+'.qmresult:',qm);
   })
  .catch(console.error);
  return score_db;
}

main();
async function main() {
  display_score({ target: document.getElementsByName('score')[0] });
  update_value({ target: document.getElementsByName('score')[0] });
  peerid = await promisedPeerId;
  gw_url = await promisedGW;

  console.log('main.gw_url:',gw_url);
  let webui_url = `${gw_url}/ipfs/${qmwebui}`;
  console.log('main.webui_url:',webui_url);
  
  let webui_elements = document.getElementsByClassName('webui');
  for (webui_element of webui_elements) {
     if (typeof(webui_element.template) == 'undefined') {
        webui_element.template = {};
     }
     if (typeof(webui_element.template.webui) == 'undefined') {
        webui_element.template.webui = webui_element.href;
     }
     webui_element.href = webui_element.template.webui.replace('webui:',webui_url);
  }
  document.getElementById('peerid').innerHTML = `<a target="_ipns" href=${gw_url}/ipns/${peerid}>${peerid}</a>`;

  /* TEST AREA ... */
  /*
  let isqm1 = await isRawLeaf('QmXqJAkSdP8eSTSXEeSRKoDYa7G1vZwaFJGiKgNFWxpUZo');
  console.log('main.isqm1:',isqm1)
  // let isqm2 = await isRawLeaf('bafkreifqrk6to5j4bi42g5skjun4rmwodetvdxuwcfqbids4ljtofv5pxa');
  let isqm2 = await isRawLeaf('QmQ9PDcjM2ueswPgsRRoGb9j868VrTmSm1NqHzomZy6a6e');
  console.log('main.isqm2:',isqm2)

  window.stop();
  */

}

async function update_root_hash() {
  document.getElementById('root_hash').innerHTML = '<img src="../img/spinner.gif" height="24">';
  let root_path = await create_root_nolog();
  document.getElementById('root_hash').innerHTML = `<a href="${gw_url}/ipfs/${root_path}>${root_path}" target=_new</a>`;
  return root_path;
}

function randomly(a,b) {
  return Math.random(1.0) > 0.5 ? -1 : 1 ;
}
function node_create(ev) {
  document.getElementById('node').style.display = ''; // to display it w/o 'blocking'
}
async function node_close(ev) {
  document.getElementById('node').style.display = 'none';
}
async function node_submit(ev) {
  let [callee, caller] = functionNameJS(); // logInfo("message !")
  let title = document.getElementsByName('title')[0].value;
  let buf = `Title: ${title} (subject)\n\n`
      buf += document.getElementsByName('node_text')[0].value;
  // let qmhash = await ipfsGetHashByContent(buf);
  let qmhash = await ipfsPostHashByContent(buf);
  console.debug(callee+'.qmhash:',qmhash);
  document.getElementsByName('qmhash')[0].value = qmhash;
  document.getElementById('qmhash').innerHTML = qmhash;
  let list_log_path = `/public/logs/${list_labelp}.log`
  list_add_node(list_log_path,qmhash);
  /* node_meta_create(qmhash); */

}

async function get_rankers_by_qm(qm) {
  let [callee, caller] = functionNameJS(); // logInfo("message !")
  let node_urn = getNid(`uri:ipfs:${qm}`);
  let rankers_token_label = `I have ranked a proposal on ${node_urn}`;
  let rankers_nid = getNid(`urn:text:${rankers_token_label}`);
  console.log(callee+'.rankers_nid:',rankers_nid);
  document.getElementsByName('rankers_nid')[0].value = rankers_nid;

  rankers_token_hash = await ipfsGetToken(rankers_nid); // Global
  document.getElementById('rankers_token_hash').innerHTML=`<a href="${gw_url}/ipfs/${rankers_token_hash}" target="_new">${rankers_token_hash}</a>`;
  let pin_status = await getPinStatus(rankers_token_hash);
  console.log(callee+'.pin_status:',pin_status);
  display_pin_image('rankers_token_pin',pin_status);

  display_status('rankers','pending');
  rankers = await ipfsFindProvs(rankers_token_hash);
  display_status('rankers','ok');
  display_rankers(rankers);
  console.log(callee+'.rankers:',rankers);
  return rankers
}
function update_rankers_token_pin(ev) {
  let [callee, caller] = functionNameJS(); // logInfo("message !")
  let pin_state = ev.target.checked;
  console.log(callee+'.pin_state:',pin_state);
  if (pin_state) { 
    return ipfsPinAdd(rankers_token_hash)
     .then( json => {
        console.log(callee+'.json:',json);
        if (json.Pins[0]) {
         return getPinStatus(rankers_token_hash)
          .then( status => { display_pin_image('rankers_token_pin',status); return status; })
         .catch(console.error)
        } else {
         return Promise.reject( false );
        } 
     })
     .catch(console.warn);
  } else {
    return ipfsPinRm(rankers_token_hash)
     .then( json => {
        console.log(callee+'.json:',json);
        return getPinStatus(rankers_token_hash)
          .then( status => { display_pin_image('rankers_token_pin',status); return status; }
          )
         .catch(console.error)
     })
     .catch(console.log);
  }
  // TODO
}

function display_pin_image(name,status) { // output
  let [callee, caller] = functionNameJS(); // logInfo("message !")
    let img = document.getElementById(name+'_img');
    img.src = '../img/pinned-'+status+'-200.png';
    let box = document.getElementsByName(name)[0];
    switch (true) {
     case (status.match(/^direct/)):
     case (status.match(/^recursive/)):
        box.checked = true; break;
     case (status.match('unpinned')):
        box.checked = false; break;
     default:
        console.warn(callee+'.status: "%s"',status);
    }

    return true;
}


async function get_qmjson_by_urn(urn) {
  let [callee, caller] = functionNameJS(); // logInfo("message !")
  let score_jsonf = `/public/logs/${urn}-state.json`;
  return mfsExists(score_jsonf).then( array =>
    { let [exists,qmjson] = array; return (exists) ? qmjson : undefined; })
  .catch(console.error);
  // getMFSFileHash(score_jsonf);
}
async function get_qmjson(qm) {
  let [callee, caller] = functionNameJS(); // logInfo("message !")
  let node_urn = getNid(`uri:ipfs:${qm}`);
  let score_jsonf = `/public/logs/${node_urn}-state.json`;
  return mfsExists(score_jsonf).then( array =>
    { let [exists,qmjson] = array; return (exists) ? qmjson : undefined; })
  .catch(console.error);
  // getMFSFileHash(score_jsonf);
}
async function node_meta_create(qm) {
  let [callee, caller] = functionNameJS(); // logInfo("message !")
  /* node meta data initialization upon creation of node
     the associated json file need to be
     shared and replicated ... i.e. its qm needs to be published

  let list_token_hash = document.getElementById('list_token_hash').innerText;
  console.log(callee+'.token_hash:',list_token_hash);
   */
  // URN: Francois Colonna  (uniq name)
  // URI: Francois C. #2425 + Paris 13 
  // URL: Paris 13

  //let node_urn = getNid(`urn:${authorp}:${titlep}`);
  let node_urn = getNid(`uri:ipfs:${qm}`);
  console.log(callee+'.node_urn:',node_urn);

  let ts = Date.now(); // timestamp
  let qmlog = 'Qm...';
  let n = 1; // number of scores
  let grade = document.getElementsByName('score')[0].value; // ranking at node's creation 
  let median = grade; // current median;
  let allowed_grades = Array.from(Array(21).keys()); // [ 0 .. 20 ];
  console.log(callee+'.allowed_grades:',allowed_grades);
  let grades_weight = allowed_grades.map(() => 0 );
      grades_weight[grade] = 1;
  console.log(callee+'.grades_weight:',grades_weight);
  let score_db = { 
    'tic': ts,
    'peerid': peerid,
    'qmtext':qm, 
    'node_urn':node_urn, 
    'n': n,
    'median': median,
    'score': allowed_grades.map( grade => {
       return [ts,grades_weight[grade],peerid];
     }) 
  }
  console.log(callee+'.score_db:',score_db);
  // score_db saved in a json file 
  let score_jsonf = `/public/logs/${node_urn}-state.json`;
  qmjson = await ipfsWriteJson(score_jsonf,score_db);
  //mfsCopy(qmjson,score_jsonf);

  
  let key = `${ts}:${shortqm(peerid)}`;
  let op = 'I';
  let record = `${key} ${ts} ${op} ${peerid} ${score} ${median}`; // history record (w/ metadata)
  // paper-trail (auditable) published under fixed label path
  let qmhistory = await history_append(ts,qm,qmjson,record);
  return qmhistory;
}

async function map_db_write(file, db) {
  let [callee, caller] = functionNameJS(); // logInfo("message !")
  let buf = ''
  for (let key of Object.keys(db)) {
    buf +=  `${key} ${db[key].join(' ')}\n`;
  }
  return ipfsWriteText(file,buf);
}

async function history_append(ts,qm,qmjson, record) {
  let [callee, caller] = functionNameJS(); // logInfo("message !")
  let node_urn = getNid(`uri:ipfs:${qm}`);

  let historyf = `/public/logs/${node_urn}-history.log`;
  if ((await mfsExists(historyf))[0] ) {
      console.log(callee+': -e ',historyf);
      qmhistory = await ipfsLogAppend(historyf,record+"\n");
  } else {
      console.log(callee+': !-e %s -> create new one ',historyf);
      qmhistory = await ipfsLogAppend(historyf,`# paper trail for ${node_urn}: ${qm} ts:${ts} qmjson:${qmjson}\n${record}\n`);
  }
  console.log(callee+'.qmhistory:',qmhistory);
  return qmhistory;
}


async function list_add_node(path,qm) {
  let [callee, caller] = functionNameJS(); // logInfo("message !")
  let ts = document.getElementsByName('ts')[0].value;
  if (ts == '') {
    ts = Date.now();
  }
  console.debug(callee+'.path:',path);
  let author = document.getElementsByName('author')[0].value; 
  let authorp = slugify(author);
  let title = document.getElementsByName('title')[0].value; 
  let category = document.getElementsByName('category')[0].value; 
  let node_path = document.getElementsByName('path')[0].value; 
  let categoryp = slugify(category)
  let titlep = slugify(title)
  record = `${ts}: ${qm} ${peerid} ${authorp}:${titlep} ${node_path}/${categoryp}\n`
  let qmlist = await ipfsLogAppend(path,record);
  document.getElementById('list_log_hash').innerHTML = `<a href=${gw_url}/ipfs/${qmlist}>${qmlist}</a>`;

}

function publish(ev) {
  return publish_root();
}
async function notify(ev) {
  let published_token = await ipfsSetToken(list_token_nid);
  document.getElementById('list_token_hash').innerHTML = published_token;
  return published_token;
}
function publish_and_notify(ev) {
 let promises = [ notify({}), publish_root({}) ];
 return Promise.all(promises);
}


async function publish_root() {
  let [callee, caller] = functionNameJS(); // logInfo("message !")
  document.getElementById('root_hash').innerHTML = '<img src="../img/spinner.gif" height="24">';
  let root_hash = await create_root_w_log();
  document.getElementById('root_hash').innerHTML = `<a href=${gw_url}/ipfs/${root_hash}>${root_hash}</a>`;
  if (typeof(root_hash) != 'undefined') {
  //console.debug(callee+'.root_hash:',root_hash);
  // update ipns_cache to have is ready for history_pull() 
  ipns_cache[peerid] = root_hash;
  return ipfsNamePublish('self','/ipfs/'+root_hash);
  } else {
   console.error(callee+'.root_hash: %s /!\\ ',root_hash);
   return root_hash;
  }

}

async function node_rank(ev) {
  let [callee, caller] = functionNameJS(); // logInfo("message !")
  let ts = Date.now(); // timestamp
  let score = document.getElementsByName('score')[0].value;
  let qmhash = document.getElementsByName('qmhash')[0].value;
  let node_urn = getNid(`uri:ipfs:${qmhash}`);

  let rankers_token_label = `I have ranked a proposal on ${node_urn}`;
  let rankers_nid = getNid(`urn:text:${rankers_token_label}`);

  document.getElementsByName('node_urn')[0].value = node_urn;
  document.getElementsByName('rankers_nid')[0].value = rankers_nid;
  
  /* var score_db; // a global var to allow reuse w/o recomputation */
  let score_jsonf = `/public/logs/${node_urn}-state.json`
  let n = 0;
  let median = 0;
  if ( (await mfsExists(score_jsonf))[0] ) {
    console.log(callee+`.score_jsonf: -e ${score_jsonf}`);
    score_db = await getJsonByMFSPath(score_jsonf);
    n = score_db.n + 1;
    score_db.peerid = peerid;
    score_db.n = n;
    score_db.score[score][0] = ts;
    score_db.score[score][1] += 1;
    console.log(callee+`.score: ${score}; w:${score_db.score[score][1]}`)

    median = compute_median(score_db,0.5);
    score_db.median = median;
    
  } else {
     console.log(callee+`.score_jsonf: ! -e ${score_jsonf}`);
     n = 1;
     median = parseInt(score);
     let allowed_grades = Array.from(Array(21).keys()); // [ 0 .. 20 ];
     let grades_weight = allowed_grades.map(() => 0 );
     grades_weight[score] = 1;
     score_db = {
        'tic':ts, 
        'peerid':peerid, 
        'qmtext':qmhash, 
        'node_urn':node_urn, 
        'rankers_nid':rankers_nid, 
        'n': n,
        'median': median,
        'score': allowed_grades.map( grade => {
              return [ts,grades_weight[grade],peerid];
              }) 
     };
     

  }
  console.debug(callee+'.score_db:',score_db);
  let qmjson = await ipfsWriteJson(score_jsonf,score_db)
  console.log(callee+'.qmjson:',qmjson);

  document.getElementById('qmjson').innerHTML = `<a href="${gw_url}/ipfs/${qmjson}">${qmjson}</a>`;
  document.getElementById('survey').innerHTML = median;
  document.getElementById('nbv').innerHTML = n;

   // add history trail
   let key = `${ts}:${shortqm(peerid)}`;
   let op = 'A';
   let record = `${key} ${ts} ${op} ${peerid} ${score} ${median}`; /// !!!
   // paper-trail (auditable) published under fixed label path
   let promised_qmhistory = history_append(ts,qmhash,qmjson,record)
   .then( qm => {
     console.debug(callee+'.qmhistory:', qm);
     // score & history,  need to be publish once history is appended ...
     return promised_root_hash = publish_root().catch(console.error);
   }).catch(console.warn)


   // announce score is cast ...
   let promised_announce = ipfsSetToken(rankers_nid);

   return score_db;
}

function compute_median(db,thres) {
  let [callee, caller] = functionNameJS(); // logInfo("message !")
    // compute median at 50%
    let n = db.n;
    let nmm = Math.floor((n-1) * thres); // n-1 as we are referenced to 0
    let nmp = Math.ceil( (n-1) * thres);
  
    console.log(callee+'.n:',n);
    console.log(callee+'.nmm:',nmm);
    console.log(callee+'.nmp:',nmp);

    // ------------------------------------------------
    let i = -1;  // just for computation (median simulation)
    console.info(callee+"...................... grades' list");
    let list = [];
    for (let grade of Object.keys(db.score)) { 
      console.log(callee+".score[%s]: %o",grade,db.score[grade] );
      if (typeof(db.score[grade]) != 'undefined') {
         let w = db.score[grade][1];
         if (w != 0) {
            for (let j of [...Array(w).keys()] ) {
               list.push(parseInt(grade));
            }
         }
      }
    }
    console.log(callee+'.list:',list);
    console.log(callee+'.computed-medianm:',list[nmm]);
    console.log(callee+'.computed-medianp:',list[nmp]);
   
    let p = -1; // p starts w/ -1 because indices are referenced to 0
    let medianm = -1;
    let medianp = -1;
    let wmm = 0;
    let wmp = 0;
    console.info(callee+'........................... medianm & medianp');
    // ------------------------------------------------
    for (let grade of Object.keys(db.score)) { 
       if (typeof(db.score[grade]) != 'undefined') {
          let w = db.score[grade][1];
          if (w != 0) {
             let log = `[p:${p+1}..${p+w}]: grade:${grade} w:${w}`;
             let num_grade = parseInt(grade);
             if (p < nmm) {
                medianm = num_grade;
                wmm = w
                   log +=` p:${p} <  nmm:${nmm} -> medianm: ${medianm}`;
             } else {
                log += ` p:${p} >= nmm:${nmm}`;
             }
             p += w;
             if (p >= nmp) {
                medianp = num_grade;
                wmp = w
                   log += ` p:${p} >= nmp:${nmp} -> medianp: ${medianp}`;
                console.log(callee+':',log);
                break;
             } else {
                log += ` p:${p} < nmp:${nmp}`;
                console.log(callee+':',log);
             }
          }
       }
    }
    // ------------------------------------------------
    median = (medianm * wmm + medianp * wmp) / (wmm + wmp); // prop... is w big : stronger attractor
    console.log(callee+'.medianm:',medianm,'w:',wmm);
    console.log(callee+'.medianp:',medianp,'w:',wmp);
    console.log(callee+'.median:',median);
    return median;
}

function node_urn_update(ev) {
  let [callee, caller] = functionNameJS(); // logInfo("message !")
  let title = ev.target.value;
  let titlep = slugify(title);
  console.debug(callee+'.titlep:',titlep);
  var node_urn = getNid(`uri:list:node:${titlep}`);
  document.getElementsByName('node_urn')[0].value = node_urn;

}
async function find_peers(ev) {
  let [callee, caller] = functionNameJS(); // logInfo("message !")
  // if (typeof(peerids) == 'undefined') {
    // let hash = await ipfsAddTextContent(editor_token);
    console.log(callee+'.list_token_nid:', list_token_nid);
    var searched_token_hash = await ipfsGetToken(list_token_nid);

    document.getElementById('searched_token_hash').innerHTML=shortqm(searched_token_hash);
    console.debug(callee+'.searched_token_hash:',searched_token_hash);
    display_status('providers','pending');
    peerids = await ipfsFindProvs(searched_token_hash); // i.e. peers_find
    display_status('providers','ok');
    display_provs(peerids);
    
  // }
  return peerids;
}


function build_qmhash_select(selid,list) {
  for ( let i=selid.length-1; i > 0; i-- ) {
   selid.remove(i);
  }
  for (let record of list) {
     let option = document.createElement('option');
     option.text = `${shortqm(record[1])} by ${record[3]}`;
     option.value = `${record[1]}`;
     selid.add(option);
  }
  return true;
}

async function get_node_list(ev) {
  let [callee, caller] = functionNameJS(); // logInfo("message !")
   document.getElementById('list_status').innerHTML='<font color=orange>busy</font>';
    let list = await node_list(peerids)
    console.debug(callee+'.list:',list);
    let qmselect = document.getElementsByName('qmhash')[0];
    build_qmhash_select(qmselect, list);
    document.getElementById('list_status').innerHTML='<font color=green>OK</font>';
  return list;
}



async function node_list(peers) {
  let [callee, caller] = functionNameJS(); // logInfo("message !")
  console.log(callee+'.list_labelp:',list_labelp);
  let logs = '';
  for(let peer of peers) {
     //if (peer == '12D3KooWJDBrt6re8zveUPZKwC3QPBid4iCguyMVuWbKMXb5HeTa') { continue; }
     let checked = document.getElementsByName('p'+peer)[0].checked;
     if (! checked) { console.info(callee+'.peer.skipped:',peer); continue; }
 
     document.getElementById('p'+peer+'_ipns_status').innerHTML = '<img src="../img/spinner.gif" height="24">';
     let cb = function(p) {
         console.log(callee+'.cb.p:',p);
         document.getElementById('p'+peer+'_ipns_status').innerHTML = `<img title="${p}" src="../img/check-mark.png" height="24">`;
      };
     document.getElementById('ipns_status').innerHTML = '<img src="../img/spinner.gif" height="24">';
     let root_path = await ipfsNameResolve(peer,cb);
     document.getElementById('ipns_status').innerHTML = '<img src="../img/check-mark.png" height="24">';
     if (root_path != qmempty) {
        let list_log_path = `${root_path}/public/logs/${list_labelp}.log`;
        let buf = await ipfsGetContentByPath(list_log_path);
        console.log(callee+'.buf:',buf);
        logs += buf;
     }
  } 
  console.log(callee+'.logs:',logs);
  let data = load_sorted_records_from_log(logs);
  return data
}

function load_sorted_records_from_log(log) {
  let [callee, caller] = functionNameJS(); // logInfo("message !")
  let data = log.slice(0,-1).split('\n'); // might have \r\n !
  console.log(callee+'.data:',data);
  let records = [];
  for (let rec of data) {
    if (rec.match(/^(?:---|#)/) ) { continue }
    let a_rec = rec.split(' ');
    a_rec[0] = a_rec[0].slice(0,-1); // chomp
    records.push(a_rec);
  }
  console.log(callee+'.records:',records);
  let selected = {};
  for (let rec of records.sort(by_stamp)) {
    let [stamp,qm,peer,nodeid,nodepath] = rec;
    console.log(callee+'.stamp: %s, nodeid: %s',stamp,nodeid);
    selected[nodeid] = rec
  }

  let sorted_records = Object.keys(selected).sort( (a,b) => {
    return compare(selected[b][0],selected[a][0]); // sort by decreasing importance !
  }).map( k => { return selected[k]; });

  console.log(callee+'.sorted_records:',sorted_records);
  return sorted_records;

}

function by_stamp(a,b) {
 // sort by increaseing stamp
 return compare(a[0],b[0]);
}

function display_status(id,s) {
  let [callee, caller] = functionNameJS(); // logInfo("message !")
  console.info(callee+'.'+id+':',s);
  let imgs = {
    'pending':'../img/spinner.gif', 'ok':'../img/check-mark.png',
    'locked':'../img/pad-ring.gif', 'unlocked':'../img/unlocked.png'
   };
  document.getElementById(id+'_status').innerHTML=`<img alt=${s} src=${imgs[s]} height="24">`;
  if (s.match('pending')) {
     document.getElementById(id+'-button').disabled=true
  } else if (s.match('ok')) { 
     document.getElementById(id+'-button').disabled=false
  }
}

async function display_provs(peerids) {
  let buf = '<ul>';
  for (peer of peerids) {
    buf += `<li><input type=checkbox name="p${peer}" checked><a target="_ipns" href="${gw_url}/ipns/${peer}"/>${peer}</a>'s <a target="_ipns" href="${gw_url}/ipns/${peer}/public/logs/${list_labelp}.log">${list_labelp}.log</a>`
    buf += `<span id="p${peer}_ipns_status"></span></li>\n`;
  }
  buf += "</ul>\n";
  document.getElementById('peerids').innerHTML = buf;
}
async function display_rankers(rankers) {
  let node_urn = document.getElementsByName('node_urn')[0].value;
  let buf = '<ul>';
  for (peer of rankers) {
    buf += `<li><input type=checkbox name="x${peer}" checked><a target="_ipns" href=${gw_url}/ipns/${peer}/public/logs>${peer}</a>'s <a target="_ipns" href="${gw_url}/ipns/${peer}/public/logs/${node_urn}-history.log">${node_urn}-history.log</a>`
    buf += `<span id="x${peer}_ipns_status"></span></li>\n`;
    promised_history_prefetch(`${gw_url}/ipns/${peer}/public/logs/${node_urn}-history.log`);
  }
  buf += "</ul>\n";
  document.getElementById('rankers').innerHTML = buf;
}

function promised_history_prefetch(url) {
  let [callee, caller] = functionNameJS(); // logInfo("message !")
   return fetch(url,{ method:'HEAD', mode:'cors' })
   .then(resp => { console.log(callee+'.url: %s (fetched)',url); return resp; })
   .catch(console.info);
}

true;