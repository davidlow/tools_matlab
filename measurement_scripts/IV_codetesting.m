% sweeps through mod current and squid current and plots 2D
% x axis = squid current, y axis = mod coil current, color = squid voltage

% change log
% 15 09 29: davidlow create


%% Initialize
clear all
close all

%% Add all paths
mainrepopath = '../';
addpath([mainrepopath, 'instrument_drivers']);
addpath([mainrepopath, 'measurement_scripts']);
addpath([mainrepopath, 'modules']);


%% Create NI daq object
path = ['Z:/data/montana_b69/Squid_Tests/150928/codetests/'];
nq = NIdaq('DL', path); %save path 

%% Set parameters to be used / saved by LoggableObj
% Add and set parameters here! not in the code! if you want more params
% add them here  All of these 'should' be saved ;)
nq.p.gain        = 500;
nq.p.rate        = 1000; %0.1 < rate < 2 857 142.9

nq.p.range       = 10; % options: 0.1, 0.2, 0.5, 1, 5, 10

nq.notes = 'testing to make sure IV is still linear + code testing!';

%% Setup scan

nq.addinput_A ('Dev1', 0, 'Voltage', nq.p.range, 'SQUID V (sense)');
nq.addoutput_A('Dev1', 0, 'Voltage', nq.p.range, 'SQUID I (source)');

nq.setrate    (nq.p.rate);

input = [0, 1, 0];
nq.setoutputdata(0, input);

[data, ~] = nq.run();

figure;
subplot(2,2,1);
plot(data);
title('sense');
subplot(2,2,2); 
plot(input);
title('source');
subplot(2,2,3);
plot(input,data);
xlabel('source');
ylabel('sense');

nq.delete();




