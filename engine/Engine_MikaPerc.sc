Engine_MikaPerc : CroneEngine {
	var pg;
	var amp = 0.3;
	var curve = -2.0;

	*new { arg context, doneCallback;
		^super.new(context, doneCallback);
	}
	
	alloc {
		pg = ParGroup.tail(context.xg);
		
		SynthDef("MikaPerc", {|t_trig, out=0, freq=55, decay=0.5,
			modSpeed=0.1, modDepth=0.5, modMul=0.3, modAdd=0.2|

			var env = EnvGen.ar(Env.perc(0.01, decay, amp, curve), doneAction: 2);
			var carFreq = freq;
			var modMod = SinOsc.ar(modSpeed, 0, modDepth / 2, modDepth / 2);
			var modFreq = freq + [modMod, 0 - modMod];
			var mod = VarSaw.ar(carFreq, 0, 0, 	modMul, modAdd);
			var car = VarSaw.ar(modFreq, 0, mod);

			Out.ar(out, (car * mod).sign * env);
		}).add;

		this.addCommand("hz", "fff", { arg msg;
			var freq = msg[1];
			var macro1 = msg[2];
			var macro2 = msg[3];
			("f" + freq + "c1" + msg[2] + "c2" + msg[3]).postln;
            Synth("MikaPerc", [
				\t_trig, 1,
				\out, context.out_b,
				\freq, freq,
				\amp, amp,

				\modDepth, macro1 * 5,
				\modMul, macro1 * 2 + 0.01,
				\modAdd, macro1 + 0.01,

				\decay, macro2 * 5,
				\modSpeed, (1 - macro2) / 10 
			], target:pg);
		});

		this.addCommand("amp", "f", { arg msg;
			amp = msg[1];
		});
	}
}