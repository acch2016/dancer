SerialPort.devices
SerialPort.devices[5]
(
p = SerialPort(
	"/dev/ttyUSB0",
	// "/dev/tty.usbserial-A50285BI",    //edit to match your port. SerialPort.listDevices
    baudrate: 115200,    //check that baudrate is the same as in arduino sketch
    crtscts: true);
)

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

        });
    }.loop;
}).play;
)
            // a3.class.postln;
            // str3.class.postln;
// 3.44444.asStringPrec(5)
// 3.44444.class
r.stop;
p.close;
s.makeWindow
s.meter
// PRENDER EL SERVIDOR
s.boot
(
SynthDef(\saw, {| cutoff = 1000, vol=0.2 |
	// arg cutoff = 1000;
    var sig;
    sig = Saw.ar([50,51]);
	sig = RLPF.ar(sig, cutoff.lag(0.02), 0.25, vol.lag(0.02));
    Out.ar(0, sig);
}).add
)

~synth = Synth(\saw, [\cutoff, 200, \vol, 0.4]);
~synth.set(\cutoff, 4000);
~synth.set(\vol, 0.1);
~synth.free

~synth = Synth(\saw, [\cutoff, ~a1.linexp(-1, 1.2, 80, 4000),
	                  \vol, ~m00s.linexp(1, 1023, 0.01, 0.4)]);
(
~control = Routine({
    {
        ~synth.set(\cutoff, ~a1.linexp(-1, 1.2, 80, 4000));
		~synth.set(\vol, ~m00s.linexp(1, 1023, 0.01, 0.4));
        0.01.wait;
    }.loop;
}).play;
)
~control.stop
~synth.free


(
Window.closeAll;
w = Window("nested", Rect(750, 50, 500, 500))
.front
.alwaysOnTop_(true);

w.view.decorator_(FlowLayout(w.bounds, 30@30, 30@30));

c = Array.fill(3, {
	arg view;
	view = CompositeView(w, 200@200)
	.background_(Color.rand);

	view.decorator_(FlowLayout(view.bounds, 5@5, 5@5));
});

Array.fill(3, {LevelIndicator(c[0], 30@150)});
Array.fill(2, {Knob(c[0], 40@40)});
Array.fill(1, {StaticText(c[0], 70@40)});
c[0].children[5].string_("MPU9250");

Array.fill(1, {Button(c[1], 190@150)});
Array.fill(1, {StaticText(c[1], 190@40)});
c[1].children[1].string_("FSR");
c[1].children[1].align_(\center);

Array.fill(1, {LevelIndicator(c[2], 30@150)});
Array.fill(2, {Knob(c[2], 40@40)});
Array.fill(1, {StaticText(c[2], 70@40)});
c[2].children[3].string_("M00S");

)

// MPU9250
c[0].children[0].
c[0].children[1].
c[0].children[2].
c[0].children[3].
c[0].children[4].

// FSR
c[1].children[0].

// M00S
c[2].children[0].
c[2].children[1].
c[2].children[2].

