import { useState, useEffect, useCallback, createContext, useContext } from "react";
import { LineChart, Line, XAxis, YAxis, ResponsiveContainer, Tooltip } from "recharts";

const ThemeContext = createContext("light");
const useTheme = () => useContext(ThemeContext);

const T = {
  light: {
    bg:"#F7F4F0", bgGrad:"radial-gradient(ellipse at 0% 0%,rgba(255,107,107,0.06) 0%,transparent 50%),radial-gradient(ellipse at 100% 0%,rgba(78,205,196,0.05) 0%,transparent 50%)",
    surface:"rgba(255,255,255,0.85)", border:"rgba(0,0,0,0.07)", borderStrong:"rgba(0,0,0,0.12)",
    text:"#1A1A2E", textSec:"#5A5A7A", textMute:"#9A9AB0",
    nav:"rgba(247,244,240,0.97)", navBorder:"rgba(0,0,0,0.08)",
    inBg:"rgba(0,0,0,0.04)", inBorder:"rgba(0,0,0,0.1)",
    inner:"rgba(0,0,0,0.025)", tag:"rgba(0,0,0,0.05)", tagC:"rgba(0,0,0,0.45)",
    shadow:"0 2px 12px rgba(0,0,0,0.07)", shadowMd:"0 4px 24px rgba(0,0,0,0.1)",
  },
  dark: {
    bg:"#0D0D14", bgGrad:"radial-gradient(ellipse at 0% 0%,rgba(255,107,107,0.07) 0%,transparent 55%),radial-gradient(ellipse at 100% 0%,rgba(78,205,196,0.06) 0%,transparent 55%)",
    surface:"rgba(255,255,255,0.03)", border:"rgba(255,255,255,0.08)", borderStrong:"rgba(255,255,255,0.12)",
    text:"#F5F0FF", textSec:"rgba(255,255,255,0.6)", textMute:"rgba(255,255,255,0.35)",
    nav:"rgba(10,10,18,0.97)", navBorder:"rgba(255,255,255,0.08)",
    inBg:"rgba(255,255,255,0.06)", inBorder:"rgba(255,255,255,0.1)",
    inner:"rgba(255,255,255,0.03)", tag:"rgba(255,255,255,0.06)", tagC:"rgba(255,255,255,0.35)",
    shadow:"none", shadowMd:"none",
  },
};

const DAYS = [
  {id:"tue",label:"TUE",name:"Lower Body A",focus:"Glutes · Quads · Hamstrings",grad:"linear-gradient(135deg,#FF6B6B,#FF8E53)",accent:"#FF6B6B",textAccent:"#E85555",emoji:"🍑",
    ex:[
      {id:"t1",name:"Barbell Hip Thrust",sets:4,rep:"8–12",rest:"2 min",type:"compound",cue:"Shoulders on bench. Drive through heels. Hard squeeze at top for 1 sec. Chin tucked — don't arch lower back."},
      {id:"t2",name:"Barbell / Goblet Squat",sets:3,rep:"8–10",rest:"2 min",type:"compound",cue:"Feet slightly wider than hips, toes out. Push the floor away. Thighs at least parallel at the bottom."},
      {id:"t3",name:"Romanian Deadlift",sets:3,rep:"8–10",rest:"2 min",type:"compound",cue:"Bar slides down thighs. Hinge at hips, feel the hamstring stretch. Drive hips forward to stand. No rounding."},
      {id:"t4",name:"Bulgarian Split Squat",sets:3,rep:"10–12 each",rest:"90 sec",type:"compound",cue:"Rear foot on bench. Drop straight down — front knee tracks toe. Drive through front heel. Start on weak leg.",tag:"replaces reverse lunge"},
      {id:"t5",name:"Side-Lying Hip Abduction",sets:3,rep:"15–20 each",rest:"60 sec",type:"isolation",cue:"Dumbbell resting on top thigh. Raise against resistance. Keep tension on the way down — no dropping.",tag:"upgraded from clamshell"},
      {id:"t6",name:"Dumbbell Lying Leg Curl",sets:3,rep:"12–15",rest:"60 sec",type:"isolation",cue:"Face down on bench, dumbbell between feet. Curl heels to glutes. 2-sec lower. Full stretch at bottom.",tag:"fills hamstring gap"},
    ]},
  {id:"thu",label:"THU",name:"Upper Body",focus:"Back · Chest · Shoulders · Arms",grad:"linear-gradient(135deg,#4ECDC4,#44CF6C)",accent:"#4ECDC4",textAccent:"#27A89E",emoji:"💪",
    ex:[
      {id:"h1",name:"Bent-Over Barbell Row",sets:4,rep:"8–10",rest:"2 min",type:"compound",cue:"Hinge ~45°. Pull bar to belly button. Elbows stay close. Squeeze shoulder blades at top."},
      {id:"h2",name:"Dumbbell Chest Press",sets:3,rep:"10–12",rest:"90 sec",type:"compound",cue:"Chest lifted, shoulders down and back. Press up without locking elbows. Lower slowly — feel the stretch."},
      {id:"h3",name:"Dumbbell Shoulder Press",sets:3,rep:"10–12",rest:"90 sec",type:"compound",cue:"Elbows in line with shoulders. Press without shrugging. Slight bend at top. Builds lean round delts — not wide shoulders."},
      {id:"h4",name:"Single-Arm Dumbbell Row",sets:3,rep:"10–12 each",rest:"60 sec",type:"isolation",cue:"Support hand on bench. Pull elbow toward hip. No torso rotation. Feel your back — not your arm."},
      {id:"h5",name:"Lateral Raise",sets:3,rep:"12–15",rest:"60 sec",type:"isolation",cue:"Light weight. Raise to shoulder height only. Shoulders stay depressed. Makes shoulders look leaner as fat drops."},
      {id:"h6",name:"Dumbbell Fly",sets:3,rep:"12–15",rest:"60 sec",type:"isolation",cue:"Slight elbow bend. Open wide until chest stretches. Bring together like hugging a barrel. Chest stays lifted."},
      {id:"h7",name:"Bicep Curl + Tricep Kickback",sets:2,rep:"12–15",rest:"45 sec",type:"isolation",cue:"Superset back to back. Fixed elbow for curls. Extend fully + rotate at top of kickback.",tag:"superset"},
    ]},
  {id:"sat",label:"SAT",name:"Lower Body B",focus:"Glutes · Adductors · Core",grad:"linear-gradient(135deg,#A855F7,#EC4899)",accent:"#A855F7",textAccent:"#8B35D6",emoji:"✨",
    ex:[
      {id:"s1",name:"Barbell Hip Thrust",sets:4,rep:"10–15",rest:"2 min",type:"compound",cue:"Slightly lighter than Tuesday. Focus on feel over load. 2-sec hard squeeze at the top every rep.",tag:"higher rep version"},
      {id:"s2",name:"Wide / Sumo Goblet Squat",sets:3,rep:"10–12",rest:"90 sec",type:"compound",cue:"Wide stance, toes out. Slight forward lean targets glutes more. Drive through heels. Squeeze inner thighs as you rise."},
      {id:"s3",name:"Kickstand / Single-Leg RDL",sets:3,rep:"10–12 each",rest:"90 sec",type:"compound",cue:"Front leg carries all the weight. Hinge until near-parallel. Feel front-side glute and hamstring stretch. Start weak side."},
      {id:"s4",name:"Lateral Band Walk",sets:3,rep:"15 steps each way",rest:"60 sec",type:"isolation",cue:"Band above knees. Half-squat position. Push knees out against band every step. Don't let feet fully touch."},
      {id:"s5",name:"Kneeling Squat",sets:3,rep:"12–15",rest:"60 sec",type:"isolation",cue:"Kneel, dumbbells at shoulders. Push hips forward using glute force only — no momentum. Hard squeeze at top."},
      {id:"s6",name:"Plank + Dead Bug",sets:2,rep:"30s / 10 each",rest:"45 sec",type:"core",cue:"Plank: rigid body, glutes squeezed. Dead bug: lower opposite arm+leg slowly, lower back pressed to floor.",tag:"replaces Russian twists"},
    ]},
];

const ALL_EX = DAYS.flatMap(d=>d.ex.map(e=>({...e,dayName:d.name,dayAccent:d.accent,dayEmoji:d.emoji})));

const MEALS=[
  {name:"Breakfast",time:"Morning",emoji:"🌅",kcal:532,prot:34,color:"#FF6B6B",items:["160g Lancashire Farm Bio Yogurt","40g Jordans No Added Sugar Granola","3 large boiled eggs"],note:"Keep this exactly as-is. Solid protein start."},
  {name:"Lunch",time:"Midday",emoji:"🥗",kcal:473,prot:67,color:"#27A89E",items:["30g plant protein shake","100g cooked chicken breast","2 Kingsmill wholemeal slices","Handful spinach + cucumber"],note:"Swap madeleines for chicken. Same calories, +30g protein."},
  {name:"Snack",time:"Afternoon",emoji:"🫙",kcal:98,prot:11,color:"#B45309",items:["100g cottage cheese"],note:"Small addition. Closes the protein gap easily."},
  {name:"Dinner",time:"Evening",emoji:"🍽️",kcal:540,prot:50,color:"#8B35D6",items:["120g cooked chicken breast","100g rice OR 150g oven potato","100g veg (broccoli, peppers, courgette)","200ml Alpro protein chocolate milk"],note:"Replaces Shin ramen. Same calories, +40g protein."},
];

const SCHEDULE=[
  {day:"Mon",type:"rest",label:"Rest",color:"#D1D5DB",emoji:"😴"},
  {day:"Tue",type:"train",label:"Lower Body A",color:"#FF6B6B",emoji:"🍑"},
  {day:"Wed",type:"cardio",label:"Jump Rope · 30 min",color:"#F59E0B",emoji:"🪢"},
  {day:"Thu",type:"train",label:"Upper Body",color:"#4ECDC4",emoji:"💪"},
  {day:"Fri",type:"cardio",label:"Jump Rope · 30 min",color:"#F59E0B",emoji:"🪢"},
  {day:"Sat",type:"train",label:"Lower Body B",color:"#A855F7",emoji:"✨"},
  {day:"Sun",type:"cardio",label:"Jump Rope · 30 min",color:"#F59E0B",emoji:"🪢"},
];

const MILESTONES=[
  {period:"1 Month",emoji:"🌱",color:"#27A89E",weight:"~74–75kg",targets:["Scale: ~74–75kg — fast start (water + fat)","Diet swaps consistent and tracked","Jump rope routine fully established","Legs and glutes noticeably firmer","All lifts progressing week on week"]},
  {period:"3 Months",emoji:"🌿",color:"#B45309",weight:"~69–70kg",targets:["Scale: ~69–70kg (−7–8kg from start)","Waist visibly narrower — ~79–81cm","Glutes beginning to project past hip bones","Upper body definition starting to emerge","Shoulders looking leaner and rounder"]},
  {period:"6 Months",emoji:"🔥",color:"#E85555",weight:"~62–64kg",targets:["Scale: ~62–64kg (−13–15kg from start)","Waist: ~73–76cm — clear hourglass forming","Glutes: ~110–113cm — visible shape and projection","Body fat ~24–27% — muscle definition appearing","Goal physique silhouette clearly visible"]},
  {period:"12 Months",emoji:"🏆",color:"#8B35D6",weight:"61–63kg",targets:["Target weight: 61–63kg — goal physique range","Body fat ~20–23% — lean and muscular","Waist-to-hip ratio ~0.70–0.73 — strong hourglass","Thick defined thighs with clear quad shape","Goal physique achieved or within touching distance"]},
];

const SK="minju-workout-v2";
async function loadLog(){try{const r=await window.storage.get(SK);return r?JSON.parse(r.value):{}}catch{return{}}}
async function saveLog(l){try{await window.storage.set(SK,JSON.stringify(l))}catch{}}
const todayKey=()=>new Date().toISOString().split("T")[0];
const fmtDate=s=>new Date(s+"T00:00:00").toLocaleDateString("en-GB",{day:"numeric",month:"short"});
const fmtShort=s=>new Date(s+"T00:00:00").toLocaleDateString("en-GB",{day:"numeric",month:"short"}).replace(" ","");
function getHist(log,exId){
  return Object.keys(log).sort().filter(d=>{const s=log[d]?.[exId];return s&&Object.values(s).some(x=>x.done&&x.kg)})
    .map(date=>{const sets=log[date][exId];const done=Object.values(sets).filter(s=>s.done&&s.kg&&s.reps);const bestKg=Math.max(...done.map(s=>Number(s.kg)));const vol=done.reduce((a,s)=>a+Number(s.kg)*Number(s.reps),0);return{date,short:fmtShort(date),bestKg,volume:Math.round(vol),sets:done}});
}

function Welcome({onDone}){
  const [p,setP]=useState(0);
  useEffect(()=>{const ts=[300,1000,1800,2600,3700].map((t,i)=>setTimeout(()=>{if(i<4)setP(i+1);else onDone();},t));return()=>ts.forEach(clearTimeout);},[]);
  return(
    <div style={{position:"fixed",inset:0,zIndex:1000,display:"flex",flexDirection:"column",alignItems:"center",justifyContent:"center",background:"#F7F4F0",overflow:"hidden"}}>
      <style>{`@keyframes sName{0%{background-position:-200% center}100%{background-position:200% center}}@keyframes fUp{0%,100%{transform:translateY(0)}50%{transform:translateY(-12px)}}@keyframes pGlow{0%,100%{box-shadow:0 0 30px rgba(255,107,107,0.15),0 0 60px rgba(168,85,247,0.08)}50%{box-shadow:0 0 50px rgba(255,107,107,0.28),0 0 90px rgba(168,85,247,0.16)}}@keyframes drift{0%,100%{transform:translateY(0) rotate(0deg)}50%{transform:translateY(-20px) rotate(180deg)}}`}</style>
      <div style={{position:"absolute",inset:0,pointerEvents:"none",overflow:"hidden"}}>
        <div style={{position:"absolute",top:"-15%",left:"-15%",width:"55vw",height:"55vw",borderRadius:"50%",background:"radial-gradient(circle,rgba(255,107,107,0.09),transparent 70%)",transition:"opacity 1.5s",opacity:p>=1?1:0}}/>
        <div style={{position:"absolute",bottom:"-15%",right:"-15%",width:"55vw",height:"55vw",borderRadius:"50%",background:"radial-gradient(circle,rgba(168,85,247,0.09),transparent 70%)",transition:"opacity 1.5s",opacity:p>=2?1:0}}/>
      </div>
      {p>=2&&[...Array(10)].map((_,i)=><div key={i} style={{position:"absolute",width:`${4+Math.random()*5}px`,height:`${4+Math.random()*5}px`,borderRadius:"50%",background:["#FF6B6B","#4ECDC4","#A855F7","#F59E0B","#EC4899"][i%5],left:`${8+Math.random()*84}%`,top:`${8+Math.random()*84}%`,opacity:0.18+Math.random()*0.22,animation:`drift ${4+Math.random()*4}s ease-in-out infinite`,animationDelay:`${Math.random()*3}s`}}/>)}
      <div style={{position:"relative",textAlign:"center",padding:"0 32px"}}>
        <div style={{marginBottom:"28px",transition:"all 0.9s cubic-bezier(0.34,1.56,0.64,1)",opacity:p>=1?1:0,transform:p>=1?"scale(1) translateY(0)":"scale(0.2) translateY(30px)"}}>
          <div style={{width:"96px",height:"96px",borderRadius:"50%",background:"linear-gradient(135deg,rgba(255,107,107,0.1),rgba(168,85,247,0.1))",border:"1.5px solid rgba(255,107,107,0.18)",display:"flex",alignItems:"center",justifyContent:"center",fontSize:"42px",margin:"0 auto",animation:p>=1?"pGlow 3s ease-in-out infinite,fUp 4s ease-in-out infinite":"none"}}>🏋️‍♀️</div>
        </div>
        <div style={{fontFamily:"'DM Mono',monospace",fontSize:"11px",letterSpacing:"0.25em",textTransform:"uppercase",color:"rgba(90,90,120,0.5)",marginBottom:"8px",transition:"all 0.6s",opacity:p>=2?1:0,transform:p>=2?"translateY(0)":"translateY(16px)"}}>welcome back</div>
        <h1 style={{fontFamily:"'Playfair Display',serif",fontSize:"56px",fontWeight:700,margin:"0 0 18px",lineHeight:1,transition:"all 0.9s cubic-bezier(0.34,1.56,0.64,1)",opacity:p>=2?1:0,transform:p>=2?"translateY(0) scale(1)":"translateY(30px) scale(0.9)",background:"linear-gradient(90deg,#FF6B6B,#FF8E53,#F59E0B,#4ECDC4,#A855F7,#EC4899,#FF6B6B)",backgroundSize:"200% auto",WebkitBackgroundClip:"text",WebkitTextFillColor:"transparent",animation:p>=2?"sName 3s linear infinite":"none"}}>Minju</h1>
        <div style={{transition:"all 0.7s ease 0.2s",opacity:p>=3?1:0,transform:p>=3?"translateY(0)":"translateY(14px)"}}>
          <div style={{fontFamily:"'DM Sans',sans-serif",fontSize:"15px",color:"rgba(90,90,120,0.6)",lineHeight:1.6,marginBottom:"14px"}}>Your goal. Your program. Your pace.</div>
          <div style={{display:"flex",alignItems:"center",justifyContent:"center",gap:"7px",flexWrap:"wrap"}}>
            {["🍑 Lower A","💪 Upper","✨ Lower B","🪢 Jump Rope"].map((tag,i)=><div key={i} style={{fontFamily:"'DM Mono',monospace",fontSize:"10px",color:"rgba(90,90,120,0.45)",background:"rgba(0,0,0,0.05)",border:"1px solid rgba(0,0,0,0.07)",borderRadius:"20px",padding:"4px 10px",transition:`all 0.4s ease ${0.08*i}s`,opacity:p>=3?1:0,transform:p>=3?"scale(1)":"scale(0.85)"}}>{tag}</div>)}
          </div>
        </div>
        <div style={{marginTop:"36px",opacity:p>=3?1:0,transition:"opacity 0.4s"}}>
          <div style={{width:"100px",height:"3px",background:"rgba(0,0,0,0.08)",borderRadius:"2px",margin:"0 auto",overflow:"hidden"}}>
            <div style={{height:"100%",background:"linear-gradient(90deg,#FF6B6B,#A855F7)",borderRadius:"2px",transition:"width 1.1s ease",width:p>=3?"100%":"0%"}}/>
          </div>
        </div>
      </div>
    </div>
  );
}

function Toggle({isDark,onToggle}){
  return(
    <div onClick={onToggle} style={{display:"flex",alignItems:"center",gap:"6px",cursor:"pointer",userSelect:"none"}}>
      <span style={{fontSize:"13px"}}>{isDark?"🌙":"☀️"}</span>
      <div style={{width:"38px",height:"22px",borderRadius:"11px",background:isDark?"rgba(168,85,247,0.4)":"rgba(0,0,0,0.1)",border:`1px solid ${isDark?"rgba(168,85,247,0.5)":"rgba(0,0,0,0.12)"}`,position:"relative",transition:"all 0.3s",flexShrink:0}}>
        <div style={{position:"absolute",top:"2px",left:isDark?"18px":"2px",width:"16px",height:"16px",borderRadius:"50%",background:isDark?"#C490FA":"#fff",boxShadow:"0 1px 4px rgba(0,0,0,0.2)",transition:"all 0.3s cubic-bezier(0.34,1.56,0.64,1)"}}/>
      </div>
    </div>
  );
}

function SetRow({num,entry,accent,onChange}){
  const th=T[useTheme()];const done=entry?.done;
  const s={background:done?`${accent}10`:th.inBg,border:`1.5px solid ${done?accent+"60":th.inBorder}`,borderRadius:"8px",padding:"7px 2px",color:th.text,fontSize:"14px",fontFamily:"'DM Mono',monospace",outline:"none",textAlign:"center",WebkitAppearance:"none",flex:1,minWidth:0,width:"100%",transition:"all 0.2s"};
  return(
    <div style={{display:"flex",alignItems:"center",gap:"4px",marginBottom:"7px",width:"100%"}}>
      <div style={{width:"20px",height:"20px",borderRadius:"50%",flexShrink:0,background:done?`${accent}18`:th.inBg,border:`1.5px solid ${done?accent:th.inBorder}`,display:"flex",alignItems:"center",justifyContent:"center",fontFamily:"'DM Mono',monospace",fontSize:"9px",fontWeight:700,color:done?accent:th.textMute,transition:"all 0.25s"}}>{num}</div>
      <input type="number" inputMode="decimal" placeholder="kg" value={entry?.kg||""} onChange={e=>onChange("kg",e.target.value)} style={s}/>
      <span style={{color:th.textMute,fontSize:"11px",fontFamily:"'DM Mono',monospace",flexShrink:0}}>×</span>
      <input type="number" inputMode="numeric" placeholder="reps" value={entry?.reps||""} onChange={e=>onChange("reps",e.target.value)} style={s}/>
      <div onClick={()=>onChange("done",!done)} style={{width:"30px",height:"30px",flexShrink:0,borderRadius:"8px",cursor:"pointer",background:done?accent:th.inBg,border:`1.5px solid ${done?accent:th.inBorder}`,display:"flex",alignItems:"center",justifyContent:"center",fontSize:"15px",transition:"all 0.2s",color:done?"#fff":th.textMute,fontWeight:700,boxShadow:done?`0 2px 8px ${accent}40`:"none"}}>{done?"✓":""}</div>
    </div>
  );
}

function ExCard({ex,day,log,today,onChange}){
  const th=T[useTheme()];const [open,setOpen]=useState(false);const [showH,setShowH]=useState(false);
  const td=log[today]?.[ex.id]||{};const done=Object.values(td).filter(s=>s.done).length;const all=done===ex.sets;
  const hist=getHist(log,ex.id);const pb=hist.reduce((b,h)=>h.bestKg>(b?.bestKg||0)?h:b,null);
  const ts={compound:{bg:"rgba(245,158,11,0.1)",c:"#B45309"},isolation:{bg:"rgba(14,165,233,0.09)",c:"#0369A1"},core:{bg:"rgba(168,85,247,0.09)",c:"#7C3AED"}}[ex.type]||{};
  const hc=useCallback((idx,f,v)=>{onChange({...log,[today]:{...(log[today]||{}),[ex.id]:{...(log[today]?.[ex.id]||{}),[idx]:{...(log[today]?.[ex.id]?.[idx]||{}),[f]:v}}}});},[log,today,ex.id,onChange]);
  return(
    <div style={{background:all?`${day.accent}0E`:th.surface,border:`1.5px solid ${all?day.accent+"45":th.border}`,borderRadius:"18px",overflow:"hidden",transition:"all 0.3s",boxShadow:all?`0 4px 20px ${day.accent}18`:th.shadow,backdropFilter:"blur(12px)"}}>
      <div onClick={()=>setOpen(!open)} style={{padding:"16px 18px",cursor:"pointer",display:"flex",justifyContent:"space-between",alignItems:"flex-start",gap:"12px"}}>
        <div style={{flex:1,minWidth:0}}>
          <div style={{display:"flex",alignItems:"center",gap:"8px",marginBottom:"7px",flexWrap:"wrap"}}>
            {all&&<span>✅</span>}
            <span style={{fontFamily:"'Playfair Display',serif",fontSize:"15px",fontWeight:700,color:th.text,lineHeight:1.2}}>{ex.name}</span>
          </div>
          <div style={{display:"flex",gap:"5px",flexWrap:"wrap",alignItems:"center"}}>
            <span style={{fontSize:"10px",fontWeight:700,padding:"3px 9px",borderRadius:"20px",background:ts.bg,color:ts.c,fontFamily:"'DM Mono',monospace",textTransform:"uppercase",letterSpacing:"0.07em"}}>{ex.type}</span>
            {ex.tag&&<span style={{fontSize:"10px",padding:"3px 9px",borderRadius:"20px",background:th.tag,color:th.tagC,fontFamily:"'DM Mono',monospace"}}>{ex.tag}</span>}
            {pb&&<span style={{fontSize:"10px",fontWeight:700,padding:"3px 9px",borderRadius:"20px",background:"rgba(245,158,11,0.12)",color:"#B45309",fontFamily:"'DM Mono',monospace"}}>🏆 {pb.bestKg}kg</span>}
          </div>
        </div>
        <div style={{textAlign:"right",flexShrink:0}}>
          <div style={{fontFamily:"'DM Mono',monospace",fontSize:"16px",fontWeight:700,color:day.textAccent}}>{ex.sets}×{ex.rep}</div>
          <div style={{fontFamily:"'DM Mono',monospace",fontSize:"10px",color:th.textMute,marginTop:"3px"}}>{ex.rest} rest</div>
          <div style={{fontFamily:"'DM Mono',monospace",fontSize:"11px",color:done>0?day.textAccent:th.textMute,marginTop:"3px",fontWeight:700}}>{done}/{ex.sets} done</div>
        </div>
      </div>
      {open&&(
        <div style={{padding:"0 12px 14px"}}>
          <div style={{height:"1.5px",background:th.border,marginBottom:"16px"}}/>
          <div style={{background:`linear-gradient(135deg,${day.accent}10,${day.accent}05)`,border:`1.5px solid ${day.accent}22`,borderRadius:"12px",padding:"12px 14px",marginBottom:"18px",fontSize:"13px",color:th.textSec,lineHeight:1.7,fontFamily:"'DM Sans',sans-serif"}}>💡 {ex.cue}</div>
          <div style={{fontFamily:"'DM Mono',monospace",fontSize:"9px",textTransform:"uppercase",letterSpacing:"0.15em",color:th.textMute,marginBottom:"12px",textAlign:"center"}}>— log today's sets —</div>
          <div style={{background:th.inner,borderRadius:"14px",padding:"10px 8px 6px",marginBottom:"14px",border:`1px solid ${th.border}`}}>
            <div style={{display:"flex",gap:"5px",marginBottom:"8px"}}>
              <div style={{width:"20px",flexShrink:0}}/>
              {["kg","reps"].map(l=><div key={l} style={{flex:1,textAlign:"center",fontFamily:"'DM Mono',monospace",fontSize:"9px",color:th.textMute,textTransform:"uppercase",letterSpacing:"0.1em"}}>{l}</div>)}
              <div style={{width:"30px",flexShrink:0}}/>
            </div>
            {Array.from({length:ex.sets},(_,i)=><SetRow key={i} num={i+1} entry={td[i]||{}} accent={day.accent} onChange={(f,v)=>hc(i,f,v)}/>)}
          </div>
          {hist.length>0&&(
            <>
              <div onClick={()=>setShowH(!showH)} style={{fontFamily:"'DM Mono',monospace",fontSize:"10px",textTransform:"uppercase",letterSpacing:"0.1em",color:day.textAccent,cursor:"pointer",marginBottom:"8px"}}>{showH?"▲":"▼"} previous sessions</div>
              {showH&&hist.slice().reverse().slice(0,4).map(({date,sets,bestKg,volume})=>(
                <div key={date} style={{background:th.inner,borderRadius:"10px",padding:"10px 12px",marginBottom:"6px",border:`1px solid ${th.border}`}}>
                  <div style={{display:"flex",justifyContent:"space-between",marginBottom:"6px"}}>
                    <span style={{fontFamily:"'DM Mono',monospace",fontSize:"10px",color:day.textAccent}}>{fmtDate(date)}</span>
                    <span style={{fontFamily:"'DM Mono',monospace",fontSize:"10px",color:th.textMute}}>best: {bestKg}kg · vol: {volume}</span>
                  </div>
                  <div style={{display:"flex",gap:"5px",flexWrap:"wrap"}}>{sets.map((s,i)=><span key={i} style={{fontFamily:"'DM Mono',monospace",fontSize:"11px",background:th.tag,borderRadius:"6px",padding:"3px 9px",color:th.textSec}}>{s.kg}kg×{s.reps}</span>)}</div>
                </div>
              ))}
            </>
          )}
        </div>
      )}
    </div>
  );
}

function TrainPage({log,onChange,saving,isDark,onToggle}){
  const th=T[useTheme()];const [di,setDi]=useState(0);const today=todayKey();const day=DAYS[di];
  const done=day.ex.reduce((a,ex)=>a+Object.values(log[today]?.[ex.id]||{}).filter(s=>s.done).length,0);
  const total=day.ex.reduce((a,ex)=>a+ex.sets,0);const pct=total>0?Math.round((done/total)*100):0;
  return(
    <div>
      <div style={{display:"flex",justifyContent:"space-between",alignItems:"flex-start",marginBottom:"22px"}}>
        <div><div style={{fontFamily:"'DM Mono',monospace",fontSize:"10px",letterSpacing:"0.2em",textTransform:"uppercase",color:th.textMute,marginBottom:"5px"}}>Home Gym · 3×/Week</div><h2 style={{fontFamily:"'Playfair Display',serif",fontSize:"28px",fontWeight:700,color:th.text,margin:0}}>Train</h2></div>
        <div style={{display:"flex",flexDirection:"column",alignItems:"flex-end",gap:"7px",paddingTop:"4px"}}><Toggle isDark={isDark} onToggle={onToggle}/><div style={{fontFamily:"'DM Mono',monospace",fontSize:"10px",color:saving?"#27A89E":th.textMute}}>{saving?"saving…":"saved ✓"}</div></div>
      </div>
      <div style={{display:"flex",gap:"8px",marginBottom:"20px"}}>
        {DAYS.map((d,i)=>{const a=i===di;return(
          <div key={d.id} onClick={()=>setDi(i)} style={{flex:1,borderRadius:"16px",padding:"13px 6px",textAlign:"center",cursor:"pointer",transition:"all 0.25s",background:a?`linear-gradient(180deg,${d.accent}18,${d.accent}06)`:th.surface,border:`1.5px solid ${a?d.accent+"60":th.border}`,boxShadow:a?`0 4px 20px ${d.accent}18`:th.shadow,transform:a?"translateY(-1px)":"none",backdropFilter:"blur(12px)"}}>
            <div style={{fontSize:"19px",marginBottom:"4px"}}>{d.emoji}</div>
            <div style={{fontFamily:"'DM Mono',monospace",fontSize:"10px",fontWeight:700,letterSpacing:"0.1em",color:a?d.textAccent:th.textMute,marginBottom:"2px"}}>{d.label}</div>
            <div style={{fontSize:"10px",fontWeight:600,color:a?th.text:th.textMute,lineHeight:1.3}}>{d.name}</div>
          </div>
        );})}
      </div>
      <div style={{background:`linear-gradient(135deg,${day.accent}16,${day.accent}05)`,border:`1.5px solid ${day.accent}30`,borderRadius:"20px",padding:"18px 20px",marginBottom:"18px",boxShadow:`0 6px 28px ${day.accent}14`}}>
        <div style={{display:"flex",justifyContent:"space-between",alignItems:"flex-start",marginBottom:"14px"}}>
          <div><div style={{fontFamily:"'Playfair Display',serif",fontSize:"20px",fontWeight:700,color:th.text,marginBottom:"3px"}}>{day.name}</div><div style={{fontFamily:"'DM Mono',monospace",fontSize:"10px",color:day.textAccent,textTransform:"uppercase",letterSpacing:"0.12em"}}>{day.focus}</div></div>
          <div style={{fontFamily:"'Playfair Display',serif",fontSize:"36px",fontWeight:700,background:day.grad,WebkitBackgroundClip:"text",WebkitTextFillColor:"transparent",lineHeight:1}}>{pct}%</div>
        </div>
        <div style={{height:"7px",borderRadius:"4px",background:"rgba(0,0,0,0.08)",overflow:"hidden"}}><div style={{height:"100%",width:`${pct}%`,background:day.grad,borderRadius:"4px",transition:"width 0.6s cubic-bezier(0.34,1.56,0.64,1)"}}/></div>
        <div style={{fontFamily:"'DM Mono',monospace",fontSize:"10px",color:th.textSec,marginTop:"8px",display:"flex",justifyContent:"space-between"}}><span>{done} of {total} sets done</span><span>~55 min</span></div>
      </div>
      <div style={{display:"flex",gap:"8px",marginBottom:"16px"}}>
        {[{l:"Compound rest",v:"2–3 min",c:"#B45309",bg:"rgba(245,158,11,0.07)"},{l:"Isolation rest",v:"60–90 sec",c:"#0369A1",bg:"rgba(14,165,233,0.07)"}].map(r=>(
          <div key={r.l} style={{flex:1,background:r.bg,border:`1.5px solid ${r.c}18`,borderRadius:"12px",padding:"10px 14px"}}>
            <div style={{fontFamily:"'DM Mono',monospace",fontSize:"9px",color:th.textMute,textTransform:"uppercase",letterSpacing:"0.1em",marginBottom:"3px"}}>{r.l}</div>
            <div style={{fontFamily:"'DM Mono',monospace",fontSize:"16px",fontWeight:700,color:r.c}}>{r.v}</div>
          </div>
        ))}
      </div>
      <div style={{display:"flex",flexDirection:"column",gap:"10px"}}>
        {day.ex.map(ex=><ExCard key={ex.id} ex={ex} day={day} log={log} today={today} onChange={onChange}/>)}
      </div>
    </div>
  );
}

function HistPage({log,isDark,onToggle}){
  const th=T[useTheme()];const dm=useTheme()==="dark";const [sel,setSel]=useState(null);
  const dates=Object.keys(log).sort().reverse();
  const totalSets=Object.values(log).reduce((a,d)=>a+Object.values(d).reduce((b,ex)=>b+Object.values(ex).filter(s=>s.done).length,0),0);
  const sx=sel?ALL_EX.find(e=>e.id===sel):null;const hd=sel?getHist(log,sel):[];const cd=hd.map(h=>({date:h.short,weight:h.bestKg}));
  return(
    <div>
      <div style={{display:"flex",justifyContent:"space-between",alignItems:"flex-start",marginBottom:"22px"}}>
        <div><div style={{fontFamily:"'DM Mono',monospace",fontSize:"10px",letterSpacing:"0.2em",textTransform:"uppercase",color:th.textMute,marginBottom:"5px"}}>Progressive Overload</div><h2 style={{fontFamily:"'Playfair Display',serif",fontSize:"28px",fontWeight:700,color:th.text,margin:0}}>History</h2></div>
        <div style={{paddingTop:"4px"}}><Toggle isDark={isDark} onToggle={onToggle}/></div>
      </div>
      <div style={{display:"flex",gap:"10px",marginBottom:"20px"}}>
        {[{l:"Sessions",v:dates.length,c:"#E85555",bg:"rgba(255,107,107,0.07)"},{l:"Sets Done",v:totalSets,c:"#27A89E",bg:"rgba(78,205,196,0.07)"}].map(s=>(
          <div key={s.l} style={{flex:1,background:s.bg,border:`1.5px solid ${s.c}22`,borderRadius:"16px",padding:"16px 12px",textAlign:"center",boxShadow:th.shadow}}>
            <div style={{fontFamily:"'Playfair Display',serif",fontSize:"30px",fontWeight:700,color:s.c,lineHeight:1}}>{s.v}</div>
            <div style={{fontFamily:"'DM Mono',monospace",fontSize:"9px",textTransform:"uppercase",letterSpacing:"0.12em",color:th.textMute,marginTop:"5px"}}>{s.l}</div>
          </div>
        ))}
      </div>
      <div style={{background:"rgba(245,158,11,0.07)",border:"1.5px solid rgba(245,158,11,0.16)",borderRadius:"14px",padding:"12px 16px",marginBottom:"20px"}}>
        <div style={{fontSize:"12.5px",color:th.textSec,fontFamily:"'DM Sans',sans-serif",lineHeight:1.6}}><span style={{color:"#B45309",fontWeight:700}}>How to use: </span>Tap any exercise to see your progression chart. That line trending up = progressive overload happening.</div>
      </div>
      {DAYS.map(d=>(
        <div key={d.id} style={{marginBottom:"16px"}}>
          <div style={{fontFamily:"'DM Mono',monospace",fontSize:"10px",textTransform:"uppercase",letterSpacing:"0.1em",color:d.textAccent,marginBottom:"9px",display:"flex",alignItems:"center",gap:"6px"}}>{d.emoji} {d.name}</div>
          <div style={{display:"flex",flexWrap:"wrap",gap:"7px"}}>
            {d.ex.map(ex=>{const h=getHist(log,ex.id).length>0;const s=sel===ex.id;return(
              <div key={ex.id} onClick={()=>setSel(s?null:ex.id)} style={{padding:"8px 14px",borderRadius:"22px",cursor:"pointer",transition:"all 0.2s",background:s?`${d.accent}16`:th.surface,border:`1.5px solid ${s?d.accent:th.border}`,fontFamily:"'DM Sans',sans-serif",fontSize:"12px",fontWeight:s?600:400,color:s?d.textAccent:th.textSec,display:"flex",alignItems:"center",gap:"5px",boxShadow:s?`0 2px 10px ${d.accent}18`:th.shadow,transform:s?"translateY(-1px)":"none",backdropFilter:"blur(12px)"}}>
                {h&&<span style={{fontSize:"10px"}}>🏆</span>}{ex.name}
              </div>
            );})}
          </div>
        </div>
      ))}
      {sx&&(
        <div style={{background:th.surface,border:`1.5px solid ${sx.dayAccent}28`,borderRadius:"18px",padding:"18px",marginBottom:"16px",boxShadow:th.shadowMd,backdropFilter:"blur(12px)"}}>
          <div style={{display:"flex",justifyContent:"space-between",alignItems:"flex-start",marginBottom:"16px"}}>
            <div><div style={{fontFamily:"'Playfair Display',serif",fontSize:"17px",fontWeight:700,color:th.text,marginBottom:"3px"}}>{sx.name}</div><div style={{fontFamily:"'DM Mono',monospace",fontSize:"10px",color:sx.dayAccent,textTransform:"uppercase",letterSpacing:"0.07em"}}>{sx.dayName}</div></div>
            {hd.length>0&&<div style={{textAlign:"right",background:"rgba(245,158,11,0.08)",border:"1.5px solid rgba(245,158,11,0.18)",borderRadius:"12px",padding:"8px 14px"}}><div style={{fontFamily:"'DM Mono',monospace",fontSize:"9px",color:"#B45309",textTransform:"uppercase",letterSpacing:"0.08em",marginBottom:"2px"}}>Personal Best</div><div style={{fontFamily:"'Playfair Display',serif",fontSize:"22px",fontWeight:700,color:"#B45309"}}>{Math.max(...hd.map(h=>h.bestKg))}kg</div></div>}
          </div>
          {cd.length>=2?(
            <div style={{marginBottom:"16px"}}>
              <div style={{fontFamily:"'DM Mono',monospace",fontSize:"9px",textTransform:"uppercase",letterSpacing:"0.1em",color:th.textMute,marginBottom:"10px"}}>Best weight per session (kg)</div>
              <ResponsiveContainer width="100%" height={150}>
                <LineChart data={cd} margin={{top:5,right:5,left:-20,bottom:5}}>
                  <XAxis dataKey="date" tick={{fill:dm?"rgba(255,255,255,0.4)":"#9A9AB0",fontSize:10,fontFamily:"'DM Mono',monospace"}} axisLine={false} tickLine={false}/>
                  <YAxis tick={{fill:dm?"rgba(255,255,255,0.4)":"#9A9AB0",fontSize:10,fontFamily:"'DM Mono',monospace"}} axisLine={false} tickLine={false} domain={["auto","auto"]}/>
                  <Tooltip contentStyle={{background:dm?"#1a1025":"#fff",border:`1.5px solid ${sx.dayAccent}35`,borderRadius:"12px",fontFamily:"'DM Mono',monospace",fontSize:"12px",boxShadow:"0 4px 20px rgba(0,0,0,0.08)"}} labelStyle={{color:th.textSec}} itemStyle={{color:sx.dayAccent}}/>
                  <Line type="monotone" dataKey="weight" stroke={sx.dayAccent} strokeWidth={3} dot={{fill:sx.dayAccent,r:5,strokeWidth:0}} activeDot={{r:7,fill:sx.dayAccent}}/>
                </LineChart>
              </ResponsiveContainer>
            </div>
          ):(
            <div style={{textAlign:"center",padding:"24px",fontFamily:"'DM Sans',sans-serif",fontSize:"13px",color:th.textMute,background:th.inner,borderRadius:"12px",marginBottom:"16px",border:`1px solid ${th.border}`}}>{hd.length===0?"Log this exercise to start tracking 📊":"One more session for your chart 📈"}</div>
          )}
          {hd.length>0&&hd.slice().reverse().slice(0,5).map(({date,sets,bestKg,volume})=>(
            <div key={date} style={{background:th.inner,borderRadius:"12px",padding:"11px 14px",marginBottom:"7px",border:`1px solid ${th.border}`}}>
              <div style={{display:"flex",justifyContent:"space-between",marginBottom:"7px"}}>
                <span style={{fontFamily:"'DM Mono',monospace",fontSize:"11px",color:sx.dayAccent}}>{fmtDate(date)}</span>
                <span style={{fontFamily:"'DM Mono',monospace",fontSize:"10px",color:th.textMute}}>best {bestKg}kg · vol {volume}</span>
              </div>
              <div style={{display:"flex",gap:"5px",flexWrap:"wrap"}}>{sets.map((s,i)=><span key={i} style={{fontFamily:"'DM Mono',monospace",fontSize:"11px",background:th.tag,borderRadius:"7px",padding:"3px 9px",color:th.textSec}}>{s.kg}kg×{s.reps}</span>)}</div>
            </div>
          ))}
        </div>
      )}
      {dates.length>0&&(
        <div style={{background:th.surface,border:`1.5px solid ${th.border}`,borderRadius:"18px",padding:"18px",backdropFilter:"blur(12px)",boxShadow:th.shadow}}>
          <div style={{fontFamily:"'Playfair Display',serif",fontSize:"17px",fontWeight:700,color:th.text,marginBottom:"14px"}}>All Sessions</div>
          {dates.slice(0,15).map(date=>{const sets=Object.values(log[date]).reduce((a,ex)=>a+Object.values(ex).filter(s=>s.done).length,0);return(
            <div key={date} style={{display:"flex",justifyContent:"space-between",alignItems:"center",padding:"10px 0",borderBottom:`1px solid ${th.border}`}}>
              <span style={{fontFamily:"'DM Mono',monospace",fontSize:"12px",color:th.textSec}}>{fmtDate(date)}</span>
              <span style={{fontFamily:"'DM Mono',monospace",fontSize:"12px",color:"#27A89E",fontWeight:700}}>{sets} sets ✓</span>
            </div>
          );})}
        </div>
      )}
    </div>
  );
}

function PlanPage({isDark,onToggle}){
  const th=T[useTheme()];const [open,setOpen]=useState("milestones");const tog=s=>setOpen(open===s?null:s);
  const D=()=><div style={{height:"1.5px",background:th.border,margin:"16px 0"}}/>;
  const Card=({id,label,emoji,children})=>(
    <div style={{background:th.surface,border:`1.5px solid ${th.border}`,borderRadius:"20px",padding:"18px 20px",marginBottom:"12px",boxShadow:th.shadow,backdropFilter:"blur(12px)"}}>
      <div onClick={()=>tog(id)} style={{display:"flex",justifyContent:"space-between",alignItems:"center",cursor:"pointer"}}>
        <div style={{fontFamily:"'Playfair Display',serif",fontSize:"18px",fontWeight:700,color:th.text}}>{emoji} {label}</div>
        <div style={{fontFamily:"'DM Mono',monospace",fontSize:"11px",color:th.textMute,background:th.tag,padding:"4px 12px",borderRadius:"20px"}}>{open===id?"▲ hide":"▼ show"}</div>
      </div>
      {open===id&&<>{children}</>}
    </div>
  );
  return(
    <div>
      <div style={{display:"flex",justifyContent:"space-between",alignItems:"flex-start",marginBottom:"22px"}}>
        <div><div style={{fontFamily:"'DM Mono',monospace",fontSize:"10px",letterSpacing:"0.2em",textTransform:"uppercase",color:th.textMute,marginBottom:"5px"}}>Diet · Cardio · Goals</div><h2 style={{fontFamily:"'Playfair Display',serif",fontSize:"28px",fontWeight:700,color:th.text,margin:0}}>The Plan</h2></div>
        <div style={{paddingTop:"4px"}}><Toggle isDark={isDark} onToggle={onToggle}/></div>
      </div>
      <Card id="milestones" label="Milestones" emoji="🎯">
        <D/>
        <div style={{background:"linear-gradient(135deg,rgba(245,158,11,0.07),rgba(168,85,247,0.06))",border:"1.5px solid rgba(245,158,11,0.16)",borderRadius:"14px",padding:"14px 16px",marginBottom:"18px"}}>
          <div style={{fontFamily:"'DM Sans',sans-serif",fontSize:"13px",color:th.textSec,lineHeight:1.65}}><span style={{color:"#B45309",fontWeight:700}}>🎯 Target: 61–63kg. </span>At 168cm this is where the muscle you're building creates the full projected glute and thick thigh look. Going below 58kg risks losing the muscle fullness that defines the goal.</div>
        </div>
        {MILESTONES.map((m,i)=>(
          <div key={i} style={{background:`linear-gradient(135deg,${m.color}09,${m.color}03)`,border:`1.5px solid ${m.color}20`,borderRadius:"16px",padding:"16px",marginBottom:"10px",boxShadow:`0 3px 14px ${m.color}08`}}>
            <div style={{display:"flex",alignItems:"center",justifyContent:"space-between",marginBottom:"12px"}}>
              <div style={{display:"flex",alignItems:"center",gap:"10px"}}><span style={{fontSize:"22px"}}>{m.emoji}</span><div style={{fontFamily:"'Playfair Display',serif",fontSize:"17px",fontWeight:700,color:m.color}}>{m.period}</div></div>
              <div style={{fontFamily:"'DM Mono',monospace",fontSize:"13px",fontWeight:700,color:m.color,background:`${m.color}12`,padding:"4px 12px",borderRadius:"20px"}}>{m.weight}</div>
            </div>
            {m.targets.map((t,j)=><div key={j} style={{display:"flex",alignItems:"flex-start",gap:"8px",marginBottom:"6px"}}><span style={{color:m.color,flexShrink:0,marginTop:"2px"}}>·</span><span style={{fontFamily:"'DM Sans',sans-serif",fontSize:"13px",color:th.textSec,lineHeight:1.55}}>{t}</span></div>)}
          </div>
        ))}
      </Card>
      <Card id="diet" label="Daily Diet" emoji="🥗">
        <D/>
        <div style={{display:"flex",gap:"8px",marginBottom:"18px"}}>
          {[{l:"Kcal",v:"~1,640",c:"#E85555",bg:"rgba(255,107,107,0.07)"},{l:"Protein",v:"~150g",c:"#27A89E",bg:"rgba(78,205,196,0.07)"},{l:"Pace",v:"2.5/mo",c:"#B45309",bg:"rgba(245,158,11,0.07)"}].map(s=>(
            <div key={s.l} style={{flex:1,background:s.bg,border:`1.5px solid ${s.c}20`,borderRadius:"14px",padding:"12px 8px",textAlign:"center"}}>
              <div style={{fontFamily:"'Playfair Display',serif",fontSize:"20px",fontWeight:700,color:s.c}}>{s.v}</div>
              <div style={{fontFamily:"'DM Mono',monospace",fontSize:"9px",textTransform:"uppercase",letterSpacing:"0.08em",color:th.textMute,marginTop:"4px"}}>{s.l}</div>
            </div>
          ))}
        </div>
        {MEALS.map((m,i)=>(
          <div key={i} style={{background:th.inner,border:`1.5px solid ${m.color}15`,borderRadius:"16px",padding:"14px",marginBottom:"10px"}}>
            <div style={{display:"flex",justifyContent:"space-between",alignItems:"center",marginBottom:"10px"}}>
              <div style={{display:"flex",alignItems:"center",gap:"10px"}}>
                <div style={{width:"42px",height:"42px",borderRadius:"50%",background:`${m.color}12`,border:`1.5px solid ${m.color}22`,display:"flex",alignItems:"center",justifyContent:"center",fontSize:"18px"}}>{m.emoji}</div>
                <div><div style={{fontFamily:"'Playfair Display',serif",fontSize:"15px",fontWeight:700,color:th.text}}>{m.name}</div><div style={{fontFamily:"'DM Mono',monospace",fontSize:"9px",color:th.textMute,textTransform:"uppercase",letterSpacing:"0.07em"}}>{m.time}</div></div>
              </div>
              <div style={{textAlign:"right"}}><div style={{fontFamily:"'DM Mono',monospace",fontSize:"14px",fontWeight:700,color:m.color}}>{m.prot}g</div><div style={{fontFamily:"'DM Mono',monospace",fontSize:"10px",color:th.textMute}}>{m.kcal} kcal</div></div>
            </div>
            {m.items.map((item,j)=><div key={j} style={{fontFamily:"'DM Sans',sans-serif",fontSize:"13px",color:th.textSec,display:"flex",alignItems:"flex-start",gap:"7px",marginBottom:"4px"}}><span style={{color:m.color,marginTop:"2px",flexShrink:0}}>·</span>{item}</div>)}
            <div style={{background:`${m.color}08`,borderRadius:"9px",padding:"8px 11px",marginTop:"10px",fontSize:"12px",color:th.textSec,fontFamily:"'DM Sans',sans-serif",lineHeight:1.55,border:`1px solid ${m.color}12`}}>{m.note}</div>
          </div>
        ))}
        <div style={{background:"rgba(245,158,11,0.06)",border:"1.5px solid rgba(245,158,11,0.16)",borderRadius:"14px",padding:"14px"}}>
          <div style={{fontFamily:"'DM Mono',monospace",fontSize:"10px",textTransform:"uppercase",letterSpacing:"0.1em",color:"#B45309",marginBottom:"12px"}}>⚡ Key swaps</div>
          {[{f:"Madeleines at lunch",t:"100g chicken breast",i:"+28g protein"},{f:"Shin ramen for dinner",t:"Chicken + rice + veg",i:"+38g protein"},{f:"Zero vegetables daily",t:"100g veg at dinner",i:"Fibre + micros"}].map((s,i)=>(
            <div key={i} style={{display:"flex",gap:"10px",alignItems:"flex-start",marginBottom:"10px",paddingBottom:"10px",borderBottom:i<2?`1px solid rgba(245,158,11,0.1)`:"none"}}>
              <div style={{flex:1}}><div style={{fontFamily:"'DM Sans',sans-serif",fontSize:"12px",color:"#E85555",textDecoration:"line-through",opacity:0.7}}>{s.f}</div><div style={{fontFamily:"'DM Sans',sans-serif",fontSize:"12px",color:"#27A89E",marginTop:"2px",fontWeight:500}}>→ {s.t}</div></div>
              <div style={{fontFamily:"'DM Mono',monospace",fontSize:"10px",color:"#B45309",background:"rgba(245,158,11,0.09)",padding:"3px 9px",borderRadius:"8px",flexShrink:0}}>{s.i}</div>
            </div>
          ))}
        </div>
      </Card>
      <Card id="cardio" label="Jump Rope" emoji="🪢">
        <D/>
        <div style={{display:"flex",flexWrap:"wrap",gap:"8px",marginBottom:"16px"}}>
          {[{l:"Sessions",v:"3×/week"},{l:"Days",v:"Wed·Fri·Sun"},{l:"Duration",v:"30 min"},{l:"Target zone",v:"Zone 4"},{l:"Target HR",v:"156+ bpm"},{l:"Format",v:"40s on·20s off"}].map(s=>(
            <div key={s.l} style={{background:"rgba(245,158,11,0.07)",border:"1.5px solid rgba(245,158,11,0.14)",borderRadius:"12px",padding:"9px 12px",minWidth:"calc(50% - 4px)"}}>
              <div style={{fontFamily:"'DM Mono',monospace",fontSize:"9px",textTransform:"uppercase",letterSpacing:"0.09em",color:th.textMute,marginBottom:"3px"}}>{s.l}</div>
              <div style={{fontFamily:"'DM Mono',monospace",fontSize:"14px",fontWeight:700,color:"#B45309"}}>{s.v}</div>
            </div>
          ))}
        </div>
        {[{w:"Weeks 1–2",f:"30s on / 30s rest",z:"Zone 3 — learning the movement",n:"Tripping is normal. Soft landings on balls of feet."},
          {w:"Weeks 3–4",f:"45s on / 15s rest",z:"Zone 3–4 — building intensity",n:"Push for Zone 4 in the final 5 minutes."},
          {w:"Week 5+",f:"40s on / 20s rest",z:"Zone 4 — 156+ bpm average",n:"Full target. Apple Watch should confirm avg 156+."}].map((p,i)=>(
          <div key={i} style={{background:th.inner,border:`1.5px solid ${th.border}`,borderRadius:"12px",padding:"12px 14px",marginBottom:"8px"}}>
            <div style={{display:"flex",justifyContent:"space-between",alignItems:"center",marginBottom:"5px"}}>
              <div style={{fontFamily:"'DM Mono',monospace",fontSize:"11px",fontWeight:700,color:"#B45309",textTransform:"uppercase",letterSpacing:"0.07em"}}>{p.w}</div>
              <div style={{fontFamily:"'DM Mono',monospace",fontSize:"10px",color:th.textMute,background:th.tag,padding:"2px 8px",borderRadius:"8px"}}>{p.f}</div>
            </div>
            <div style={{fontFamily:"'DM Sans',sans-serif",fontSize:"12px",color:th.textSec,marginBottom:"3px",fontWeight:500}}>{p.z}</div>
            <div style={{fontFamily:"'DM Sans',sans-serif",fontSize:"12px",color:th.textMute,lineHeight:1.5}}>{p.n}</div>
          </div>
        ))}
        <div style={{background:"rgba(39,168,158,0.07)",border:"1.5px solid rgba(39,168,158,0.16)",borderRadius:"12px",padding:"11px 14px",marginTop:"8px",fontSize:"12.5px",color:th.textSec,fontFamily:"'DM Sans',sans-serif",lineHeight:1.6}}>
          <span style={{color:"#27A89E",fontWeight:700}}>Apple Watch: </span>Select "Jump Rope" workout. Swipe left for live Zone display. Foam mat under feet protects the floor.
        </div>
      </Card>
      <Card id="schedule" label="Weekly Schedule" emoji="📅">
        <D/>
        {SCHEDULE.map((d,i)=>(
          <div key={i} style={{display:"flex",alignItems:"center",gap:"14px",padding:"11px 0",borderBottom:`1px solid ${th.border}`}}>
            <div style={{width:"36px",fontFamily:"'DM Mono',monospace",fontSize:"11px",fontWeight:700,color:th.textMute,flexShrink:0}}>{d.day}</div>
            <span style={{fontSize:"18px",flexShrink:0}}>{d.emoji}</span>
            <div style={{fontFamily:"'DM Sans',sans-serif",fontSize:"13px",fontWeight:600,color:d.type==="rest"?th.textMute:th.text,flex:1}}>{d.label}</div>
            <div style={{width:"9px",height:"9px",borderRadius:"50%",background:d.color,flexShrink:0,boxShadow:d.type!=="rest"?`0 0 7px ${d.color}60`:"none"}}/>
          </div>
        ))}
        <div style={{marginTop:"14px",background:th.inner,borderRadius:"12px",padding:"11px 14px",fontSize:"12.5px",color:th.textSec,fontFamily:"'DM Sans',sans-serif",lineHeight:1.6,border:`1px solid ${th.border}`}}>
          Plus walking to work Mon–Fri. Total deficit targets 2.5kg/month. Judge on monthly averages — daily weight fluctuates 1–2kg normally.
        </div>
      </Card>
    </div>
  );
}

function Nav({active,onChange,isDark}){
  const th=T[isDark?"dark":"light"];const tabs=[{id:"train",label:"Train",emoji:"🏋️"},{id:"history",label:"History",emoji:"📈"},{id:"plan",label:"Plan",emoji:"📋"}];
  return(
    <div style={{position:"fixed",bottom:0,left:0,right:0,zIndex:100}}>
      <div style={{background:th.nav,backdropFilter:"blur(24px)",borderTop:`1px solid ${th.navBorder}`,padding:"10px 0 max(10px,env(safe-area-inset-bottom))"}}>
        <div style={{maxWidth:"480px",margin:"0 auto",display:"flex",justifyContent:"space-around"}}>
          {tabs.map(tab=>{const a=active===tab.id;return(
            <div key={tab.id} onClick={()=>onChange(tab.id)} style={{flex:1,display:"flex",flexDirection:"column",alignItems:"center",gap:"3px",cursor:"pointer",padding:"4px 0",transition:"all 0.2s"}}>
              <span style={{fontSize:"22px",filter:a?"none":"grayscale(0.5) opacity(0.45)",transition:"all 0.25s",transform:a?"scale(1.1)":"scale(1)"}}>{tab.emoji}</span>
              <span style={{fontFamily:"'DM Mono',monospace",fontSize:"9px",letterSpacing:"0.1em",fontWeight:700,color:a?th.text:th.textMute,transition:"all 0.2s"}}>{tab.label.toUpperCase()}</span>
              <div style={{width:a?"24px":"0px",height:"2.5px",borderRadius:"2px",background:"linear-gradient(90deg,#FF6B6B,#A855F7)",transition:"width 0.3s cubic-bezier(0.34,1.56,0.64,1)"}}/>
            </div>
          );})}
        </div>
      </div>
    </div>
  );
}

export default function App(){
  const [page,setPage]=useState("train");const [log,setLog]=useState({});const [saving,setSaving]=useState(false);const [loaded,setLoaded]=useState(false);const [showW,setShowW]=useState(true);const [fading,setFading]=useState(false);const [isDark,setIsDark]=useState(false);
  const th=T[isDark?"dark":"light"];
  useEffect(()=>{loadLog().then(l=>{setLog(l);setLoaded(true);});},[]);
  const handleChange=useCallback(async nl=>{setLog(nl);setSaving(true);await saveLog(nl);setSaving(false);},[]);
  const handleDone=useCallback(()=>{setFading(true);setTimeout(()=>setShowW(false),700);},[]);
  return(
    <ThemeContext.Provider value={isDark?"dark":"light"}>
      <div style={{minHeight:"100vh",background:th.bg,backgroundImage:th.bgGrad,fontFamily:"'DM Sans',sans-serif",paddingBottom:"90px",transition:"background 0.4s ease"}}>
        <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:ital,wght@0,600;0,700;1,600&family=DM+Sans:wght@300;400;500;600&family=DM+Mono:wght@400;500;700&display=swap" rel="stylesheet"/>
        <style>{`*{box-sizing:border-box}input[type=number]::-webkit-inner-spin-button,input[type=number]::-webkit-outer-spin-button{-webkit-appearance:none;margin:0}`}</style>
        {showW&&<div style={{opacity:fading?0:1,transition:"opacity 0.7s ease",pointerEvents:fading?"none":"all"}}><Welcome onDone={handleDone}/></div>}
        <div style={{opacity:showW&&!fading?0:1,transition:"opacity 0.6s ease 0.15s"}}>
          {!loaded?(
            <div style={{minHeight:"100vh",display:"flex",alignItems:"center",justifyContent:"center"}}>
              <div style={{textAlign:"center"}}><div style={{fontSize:"36px",marginBottom:"12px"}}>🏋️‍♀️</div><div style={{fontFamily:"'DM Mono',monospace",fontSize:"12px",color:th.textMute,letterSpacing:"0.1em"}}>Loading...</div></div>
            </div>
          ):(
            <>
              <div style={{maxWidth:"480px",margin:"0 auto",padding:"28px 16px 0"}}>
                {page==="train"&&<TrainPage log={log} onChange={handleChange} saving={saving} isDark={isDark} onToggle={()=>setIsDark(!isDark)}/>}
                {page==="history"&&<HistPage log={log} isDark={isDark} onToggle={()=>setIsDark(!isDark)}/>}
                {page==="plan"&&<PlanPage isDark={isDark} onToggle={()=>setIsDark(!isDark)}/>}
              </div>
              <Nav active={page} onChange={setPage} isDark={isDark}/>
            </>
          )}
        </div>
      </div>
    </ThemeContext.Provider>
  );
}
