SerialPort.devices
SerialPort.devices[5]
(
p = SerialPort(
	"/dev/ttyUSB0",
	// "/dev/tty.usbserial-A50285BI",    //edit to match your port. SerialPort.listDevices
    baudrate: 115200,    //check that baudrate is the same as in arduino sketch
    crtscts: true);
)
/*
p.read
p.close
(
x = [];
30.do{x = x.add(p.read)};
x.collect(_.asAscii);
)*/

//  9 decimal value ascii of \t
// 10 decimal value ascii of \n
// 13 decimal value ascii of \r
// http://doc.sccode.org/Reference/Literals.html
// http://danielnouri.org/docs/SuperColliderHelp/Language/Partial-Application.html

/*(
r2 = Routine({
    var ascii, byte;
    {
        byte = p.read;
        ascii = p.read.asAscii;
        if(9 == p.read
    }.loop
}).play;
)*/

(
r= Routine({
    var byte, str, str1, str2, str3;
    {
        if(p.read==10, {
            str1 = "";
            str2 = "";
            str3 = "";

            while({byte = p.read; byte !=9 }, {
                str1 = str1++byte.asAscii;
            });
            ~res1 = str1.asFloat;
            ("x:"+ ~res1.asStringPrec(5)).post;

            while({byte = p.read; byte !=9 }, {
                str2 = str2++byte.asAscii;
            });
            ~res2 = str2.asFloat;
            ("  y:"+ ~res2.asStringPrec(5)).post;

            while({byte = p.read; byte !=13 }, {
                str3 = str3++byte.asAscii;
            });
            ~res3 = str3.asFloat;
            ("  z:"+ ~res3.asStringPrec(5)).postln;
            // res3.class.postln;
            // str3.class.postln;
        });
    }.loop;
}).play;
)

// 3.44444.asStringPrec(5)
// 3.44444.class
r.stop;
p.close;
s.makeWindow

(
SynthDef(\saw, {
    arg cutoff = 1000;
    var sig;
    sig = Saw.ar([50,51]);
    sig = RLPF.ar(sig,cutoff.lag(0.02).postln, 0.25, 0.2);
    Out.ar(0, sig);
}).add
)

~synth = Synth(\saw, [\cutoff, 200]);
~synth.set(\cutoff, 4000);
~synth.free

~synth = Synth(\saw, [\cutoff, ~res1.linexp(-1, 1.2, 80, 4000)]);
(
~control = Routine({
    {
        ~synth.set(\cutoff, ~res1.linexp(-1, 1.2, 80, 4000));
        0.01.wait;
    }.loop;
}).play;
)
~control.stop
~synth.free
