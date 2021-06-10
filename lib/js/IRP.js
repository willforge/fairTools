
/*
  dependencies sha1,
  need a require([],,)
*/

(function(){

const IRP = {};


// Global Registry
const deps = {};
const mutables = { 'fetch' : null };
const registry = { };
IRP.mutables = mutables;
IRP.registry = registry;


// ------------------------------------------------------------------------------------------
const provide = function (caller,name,provide_n_build) {
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
IRP.provide = provide;

const build = function (caller,name,compute,proms) {
   return Promise.all(proms).then( results => {
     let value = compute(results);
     console.log(caller+'.build.'+name+':',value);
     return value;
   });
}
IRP.build = build;

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

// ------------------------------------------------------------------------------------------
// build Deps Acyclic Graph ...
const dag_build = function (parent,name) {
   console.log('dag_build:',deps);
   if (typeof(deps[name])) {
    deps[name] = [];
   }
   deps[name].push(parent);
   return deps;
}
IRP.dag_build = dag_build;

function hasChanged(name,hash) {
  let key = mutables[name];
  if ('undefined' != typeof registry[key]) { return true; }
  return (hash != registry[key]);
}

function isValid(name) {
   return (typeof(mutables[name]) != 'undefined' && registry[name] != null);
}

function invalidate(parent,indent) {
  const key = parent.replace('provide_?','').toLowerCase;
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



window.IRP = IRP;
return IRP;
})();

