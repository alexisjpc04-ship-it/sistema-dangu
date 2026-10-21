document.querySelectorAll('[data-dialog]').forEach(b=>b.addEventListener('click',()=>document.getElementById(b.dataset.dialog).showModal()));
document.querySelectorAll('[data-close]').forEach(b=>b.addEventListener('click',()=>b.closest('dialog').close()));
document.querySelectorAll('form[data-confirm]').forEach(f=>f.addEventListener('submit',e=>{if(!confirm(f.dataset.confirm))e.preventDefault();}));
document.querySelectorAll('input.uppercase').forEach(i=>i.addEventListener('blur',()=>i.value=i.value.trim().toLocaleUpperCase('es-PE')));
document.getElementById('search-personal')?.addEventListener('input',function(){let q=this.value.toLocaleUpperCase('es-PE');document.querySelectorAll('#personal-table tbody tr').forEach(r=>r.hidden=!r.textContent.toLocaleUpperCase('es-PE').includes(q));});
document.getElementById('print')?.addEventListener('click',()=>window.print());
const clock=document.getElementById('clock');if(clock){const tick=()=>clock.textContent=new Intl.DateTimeFormat('es-PE',{timeZone:'America/Lima',hour:'2-digit',minute:'2-digit',second:'2-digit',hour12:false}).format(new Date());tick();setInterval(tick,1000);}

document.querySelectorAll("[data-show-password]").forEach(control=>control.addEventListener("change",()=>control.closest("form").querySelectorAll("input[name=actual],input[name=password],input[name=password_confirmation]").forEach(input=>input.type=control.checked?"text":"password")));
