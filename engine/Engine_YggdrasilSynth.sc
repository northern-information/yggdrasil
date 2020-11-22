Engine_YggdrasilSynth : CroneEngine {
	var <synths;
	var <voices;
	var pg;
	var amp = 0.3;

	*new { arg context, doneCallback;
		^super.new(context, doneCallback);
	}
	
	alloc {
		pg = ParGroup.tail(context.xg);

		voices = List[];

		// dirty dirty dirty!!!
		synths = [
			\PolyPercMacrod, { |out, freq, amp, macro1, macro2|
				var cutoff = (macro1 * 127).midicps;
				var release = macro2 * 5;
				var snd = Pulse.ar(freq, 0.5);
				var filt = MoogFF.ar(snd, cutoff, 2);
				var env = Env.perc(level: amp, releaseTime: release).kr(2);

				Out.ar(out, (filt*env).dup);
			},
			\MikaPerc, { |out, freq, amp, macro1, macro2|
				var modDepth, modMul, modAdd, decay, modSpeed;
				var env, carFreq, modMod, modFreq, mod, car;

				macro1 = (macro1 * 1.2).pow(3);

				modDepth = macro1 * 5;
				modMul = macro1 * 2 + 0.01;
				modAdd = macro1 + 0.01;
				decay = macro2 * 7;
				modSpeed = (1 - macro2) / 10;

				env = EnvGen.ar(Env.perc(0.01, decay, amp / 3, (-3.0)), doneAction: 2);
				carFreq = freq;
				modMod = SinOsc.ar(modSpeed, 0, modDepth / 2, modDepth / 2);
				modFreq = freq + [modMod, 0 - modMod];
				mod = VarSaw.ar(carFreq, 0, 0, 	modMul, modAdd);
				car = VarSaw.ar(modFreq, 0, mod);

				Out.ar(out, (car * mod).sign * env);
			},
			\YggyToast, { |out, freq, amp, macro1, macro2, t_trig|
				var modEnv, carEnv;
				var harm;
				var mod1, mod2, modXfade, modTotal;
				var signal;
				var randMacro1 = {
					Demand.kr(t_trig, 0, Dwhite(macro1, macro1, inf));
				};

				modEnv = EnvGen.ar(Env.perc(
					attackTime: (macro2 * 1.3).pow(6),
					releaseTime: 0.02 + (macro2 * 6),
					level: 0.2 + (amp * macro1 * 2).pow(5),
					curve: -3
				));

				carEnv = EnvGen.ar(Env.perc(
					attackTime: (macro2 * 2).pow(2.5),
					releaseTime: 0.05 + (macro2 * 7),
					level: amp / 5,
					curve: -3
				), doneAction: 2);

				freq = SinOsc.ar(
					(1.001 - macro2) * 5,
					0,
					macro2 * 0.2,
					freq.cpsmidi
				).midicps;

				harm = 1 + (macro1 * 2.22).pow(3);

				mod1 = SinOscFB.ar(harm.floor * freq + [randMacro1.(), randMacro1.()],
					feedback:(1 - macro2) * 1.5 * macro1);
				mod2 = SinOscFB.ar(harm.ceil * freq + [randMacro1.(), randMacro1.()],
					feedback:(1 - macro2) * 1.5 * macro1);
				modXfade = harm - harm.floor;
				modTotal = ((mod1 * modXfade) + (mod2 * (1 - modXfade))) * modEnv;

				signal = SinOsc.ar(freq, modTotal, carEnv);

				Out.ar(out, signal);
			}
		].asDict;
		
		synths.keys.do({ arg name;
			("defining name: " ++ name).postln;
			SynthDef(name, synths[name]).add;
		});
		
		this.addCommand("hz", "sfff", { arg msg;
			var synthName = msg[1];
			var freq = msg[2];
			var macro1 = msg[3];
			var macro2 = msg[4];
			var voice = Synth(synthName, [
				\out, context.out_b,
				\freq, freq,
				\amp, amp,
        \macro1, macro1,
        \macro2, macro2,
				\t_trig, 1
			], target:pg);
            voices.add(voice);
		});

		this.addCommand("panic", "", {
			"PANIC NOW!".postln;
			voices.do({|voice| voice.free; });
			voices = List[];
		});

		this.addCommand("amp", "f", { arg msg;
			amp = msg[1];
		});
	}
}
