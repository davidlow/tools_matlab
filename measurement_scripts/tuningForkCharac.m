%% Initialize
clear all
close all

%% Add all paths
mainrepopath = '../';
addpath([mainrepopath, 'instrument_drivers']);
addpath([mainrepopath, 'measurement_scripts']);
addpath([mainrepopath, 'modules']);



%% Create NI daq and SR830 lock-in object
nidaq = NIdaq('JKN', 'Z:/data/montana_b69/TuningForkChar/150924/');
%lockin = SR830(); % uncomment if using lock-in's sine out
funcgen = Agilent33250A('JKN', 'Z:/data/montana_b69/TuningForkChar/150924/');

%% Set parameters to be used / saved by LoggableObj
% Add and set parameters here! not in the code! if you want more params
% add them here  All of these 'should' be saved ;)
% nidaq.p.gain       = 500;
% nidaq.p.lpf0       = 100;
% nidaq.p.mod_curr   = 70e-6;
% nidaq.p.mod_biasr   = 12e3;
nidaq.p.rate       = 100; % Hz; number of data points (input or output) passed (inward or outward) per second
nidaq.p.range      = 10; % options: 0.1, 0.2, 0.5, 1, 2, 5, 10
%nidaq.p.src_amp    = .001; % in Volts???
nidaq.p.src_numpts = 10; % number of data points
%nidaq.p.squid_biasr  = 5e3;
%nidaq.p.T          = 9.0;
%nidaq.p.Terr       = .060;

nidaq.notes = 'Bare tuning fork';

% Non-savable params - set here!
kevTf = struct();
kevTf.freq_step = 1; % Hz
kevTf.freq_min = 32750; % Hz
kevTf.freq_max = 32780; % Hz
kevTf.timeConstant = 0.1; % s; lock-in time constant
kevTf.sensitivity = 0.01; % V; lock-in sensitivity (max range of input)
kevTf.expand = 1; % lock-in CH1 or 2 output voltage multiplication factor
kevTf.offset = 0; % lock-in CH1 or 2 output voltage offset
kevTf.sourceAmp = 0.004; % V; lock-in/function generator sine output amplitude
kevTf.maxCHVoltRange = 10; % V; max range of lock-in CH1 & 2 BNC outputs
kevTf.inputLockinCH1Num = 0; % DAQ input channel number for lock-in CH1 (voltage X)
kevTf.inputLockinCH2Num = 1; % DAQ input channel number for lock-in CH2 (voltage Y)
%kevTf.outputOpAmpBiasNum = 3; % DAQ output channel number for opamp power voltage < +/- 15 V.
kevTf.dummyNum = 0; % DAQ output channel number for dummy output to control when the DAQ stops sensing input.
nidaq.p.kevTf = kevTf;

% freqSetVals = linspace(kevTf.freq_min, kevTf.freq_max, (kevTf.freq_max-kevTf.freq_min)/kevTf.freq_step + 1) % might be better than the colon operator since will always include endpoints
freqSetVals = kevTf.freq_min:kevTf.freq_step:kevTf.freq_max;

%% Setup scan
nidaq.setrate(nidaq.p.rate);
nidaq.addinput_A ('Dev1', kevTf.inputLockinCH1Num, 'Voltage', nidaq.p.range, 'V-X');
nidaq.addinput_A ('Dev1', kevTf.inputLockinCH2Num, 'Voltage', nidaq.p.range, 'V-Y');
%nidaq.addoutput_A('Dev1', kevTf.outputOpAmpBiasNum, 'Voltage', nidaq.p.range, 'opAmp-Voltage');
nidaq.addoutput_A('Dev1', kevTf.dummyNum, 'Voltage', nidaq.p.range, 'dummy');

%% Setup data
desout = {zeros(1,nidaq.p.src_numpts)};%,...
          %nidaq.p.mod_curr * nidaq.p.mod_biasr *    linspace(1,1   ,nidaq.p.src_numpts)  ...
         %};
%nidaq.setoutputdata(kevTf.outputOpAmpBiasNum,desout{1}); % will be used for opAmp power voltage
nidaq.setoutputdata(kevTf.dummyNum,desout{1}); % dummy output so that DAQ keeps reading input

%% Run / collect data

pause('on')
funcgen.applywave('SIN',freqSetVals(1),2*kevTf.sourceAmp,0);

for i = 1:length(freqSetVals)
	%lockin.setFreq(freqSetVals(i)); % uncomment this & comment below if using lock-in's sine out
    funcgen.setFreq(freqSetVals(i)); %uncomment this & comment above if using agilent 33250A
	pause(10*kevTf.timeConstant);
	freqReadVals(i) = funcgen.getFreq();
    
    [data, time] = nidaq.run();
	XVals(i) = (mean(data(:,1))/kevTf.maxCHVoltRange/kevTf.expand+kevTf.offset)*kevTf.sensitivity; % READS CH1, VX in Vrms, with appropriate proportionality constant, ON LOCK IN FROM DAQ
	YVals(i) = (mean(data(:,2))/kevTf.maxCHVoltRange/kevTf.expand+kevTf.offset)*kevTf.sensitivity; % READS CH2, VY in Vrms, with appropriate proportionality constant, ON LOCK IN FROM DAQ
    
    %pause(9999) % for debugging purposes
end


%% Plot
ampVals = sqrt(XVals.^2+YVals.^2); % in Vrms
phaseVals = atan(YVals./XVals)/pi()*180; % in degrees
[Ax, Line1, Line2] = plotyy(freqReadVals/1000, ampVals*1000, freqReadVals/1000, phaseVals);
%plot(freqReadVals/1000, ampVals)
hold on
% title(['gain=',           num2str(nidaq.p.gain),                 ...
       % ', lp f_0 =',      num2str(nidaq.p.lpf0),                 ...
       % ', hz, rate =',    num2str(nidaq.p.rate),                 ...
       % ', hz r_{bias} = ' num2str(nidaq.p.squid_biasr),            ...
       % ', T = '           num2str(nidaq.p.T)                     ...
       % ]);
xlabel('Frequency (kHz)','fontsize',20);
%ylabel('Amplitude (Vrms)','fontsize',20);
ylabel(Ax(1),'Amplitude (mVrms)','fontsize',20);
ylabel(Ax(2),'Phase (deg)','fontsize',20);

nidaq.delete();
%lockin.delete(); % uncomment if using lock-in's sine out
funcgen.delete();