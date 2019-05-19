// PRENDER EL SERVIDOR
s.boot
s.quit
SerialPort.devices
SerialPort.devices[5]
SerialPort.devices[32]

(
p = SerialPort(
	"/dev/ttyUSB0",
	// "/dev/tty.usbserial-A50285BI",    //edit to match your port. SerialPort.listDevices
    baudrate: 115200,    //check that baudrate is the same as in arduino sketch
    crtscts: true);
)

(
Window.closeAll;
w = Window("nested", Rect(750, 50, 500, 500))
.front
.alwaysOnTop_(true);

w.view.decorator_(FlowLayout(w.bounds, 30@30, 30@30));

~c = Array.fill(4, {
	arg view;
	view = CompositeView(w, 200@200)
	.background_(Color.rand);

	view.decorator_(FlowLayout(view.bounds, 5@5, 5@5));
});
Array.fill(1, {StaticText(    ~c[0], 22@155)});
Array.fill(3, {LevelIndicator(~c[0], 20@150)});
Array.fill(1, {Knob(          ~c[0], 40@40)});
// ~c[0].view.decorator.nextLine;
Array.fill(1, {StaticText(    ~c[0], 190@30)});
~c[0].children[0].string_("1g"++$\n++$\n++$\n++$\n++"0g"++$\n++$\n++$\n++$\n++"-1g");//Char ctrl+d
~c[0].children[0].align_(\top);
~c[0].children[5].string_("MPU9250");
~c[0].children[5].align_(\center);

Array.fill(1, {LevelIndicator(~c[1], 30@150)});
Array.fill(1, {Button(    ~c[1], 150@150)});
Array.fill(1, {StaticText(~c[1], 190@40)});
~c[1].children[2].string_("FSR");
~c[1].children[2].align_(\center);


Array.fill(2, {Knob(          ~c[2], 40@40)});
Array.fill(1, {StaticText(    ~c[2], 190@40)});
~c[2].children[2].string_("M00S");
~c[2].children[2].align_(\center);

Array.fill(1, {StaticText(   ~c[3], 20@160)});
Array.fill(1, {FreqScopeView(~c[3], 160@160)});
Array.fill(1, {StaticText(   ~c[3], 190@20)});
~c[3].children[0].string_("dB");
~c[3].children[0].align_(\topLeft);
~c[3].children[2].string_("f");
~c[3].children[2].align_(\right);
)
~c[0].children[5].class
//  9 decimal value ascii of \t
// 10 decimal value ascii of \n
// 13 decimal value ascii of \r
// http://doc.sccode.org/Reference/Literals.html
// http://danielnouri.org/docs/SuperColliderHelp/Language/Partial-Application.html

(
r= Routine({
    var byte, str, str1, str2, str3, str4;
    {
        if(p.read==10, {
			str  = "";
            str1 = "";
            str2 = "";
            str3 = "";
			str4 = "";

			while({byte = p.read; byte !=9  }, { str  = str ++byte.asAscii; });
            ~fsr = str.asInteger;
			// ("fsr:"+ ~fsr).post;

            while({byte = p.read; byte !=9  }, { str1 = str1++byte.asAscii; });
            ~a1 = str1.asFloat;
			// ("x:"+ ~a1.asStringPrec(5)).post;

            while({byte = p.read; byte !=9  }, { str2 = str2++byte.asAscii; });
            ~a2 = str2.asFloat;
			// ("  y:"+ ~a2.asStringPrec(5)).post;

            while({byte = p.read; byte !=9  }, { str3 = str3++byte.asAscii; });
            ~a3 = str3.asFloat;
			// ("  z:"+ ~a3.asStringPrec(5)).post;

			while({byte = p.read; byte !=13 }, { str4 = str4++byte.asAscii; });
            ~m00s = str4.asInteger;
			// ("  m00s:"+ ~m00s).postln;


			// if (~a1 < 1, {~c[0].children[0].value = ~a1.linlin(-1, 1, 0, 0.9); }.defer;);
			{~c[0].children[1].value = ~a1.linlin(-1, 1, 0, 1); }.defer;
			{~c[0].children[2].value = ~a2.linlin(-1, 1, 0, 1); }.defer;
			{~c[0].children[3].value = ~a3.linlin(-1, 1, 0, 1); }.defer;

			// {~c[1].children[0].value = ~fsr.linexp(1, 1023, 0, 1); }.defer;

        });
    }.loop;
}).play;
)


r.stop;
p.close;
s.makeWindow
s.meter
s.freqscope

(
SynthDef(\saw, {| cutoff = 1000, vol=0.2, i_mod = 0|
	// arg cutoff = 1000;
    var sig, mod;
	// mod = SinOsc.ar(i_mod,0,25,50);
    sig = Saw.ar([50,51]);
	sig = RLPF.ar(sig, cutoff.lag(0.02), 0.25, vol.lag(0.02));
    Out.ar(0, sig);
}).add
)

// ~synth = Synth(\saw, [\cutoff, 200, \vol, 0.4, \i_mod, 0.5]);
/*~synth = Synth(\saw, [\cutoff, 200, \vol, 0.4]);
~synth.set(\cutoff, 4000);
~synth.set(\vol, 0.1);
~synth.set(\i_mod, 0);
~synth.free*/
(
~synth = Synth(\saw, [\cutoff, ~a1.linexp(-1, 1.2, 80, 4000),
	                  \vol, ~fsr.linexp(1, 1000, 0.01, 0.4)]);
)
(
~control = Routine({
    {
        ~synth.set(\cutoff, ~a1.linexp(-1, 1.2, 80, 4000));
		~synth.set(\vol, ~fsr.linexp(1, 1000, 0.01, 0.4));

        0.01.wait;
    }.loop;
}).play;
)
~control.stop
~synth.free


