// TODO
// - set up outs properly!!!!
// - make this be a real engine!!!!
// - match parameters to spec!!!!
// - collapse all the various parameters into macros intelligently
//     - something besides an obvious linear mapping would be neat
//     - e.g. fades between various states, physics-y things, etc.
// - do something kind of smart with the t_trig trigger
(
SynthDef(\mika, {|t_trig, out=0, freq=55, decay=0.5, volume=1, curve=(-4.0),
	modSpeed=0.1, modDepth=0.5, modMul=0.3, modAdd=0.2|

	var env = EnvGen.ar(Env.perc(0.01, decay, volume, curve), doneAction: 2);
	var carFreq = freq;
	var modMod = SinOsc.ar(modSpeed, 0, modDepth / 2, modDepth / 2);
	var modFreq = freq + [modMod, 0 - modMod];
	var mod = VarSaw.ar(carFreq, 0, 0, 	modMul, modAdd);
	var car = VarSaw.ar(modFreq, 0, mod);

	Out.ar(out, (car * mod).sign * env);
}).add;
)