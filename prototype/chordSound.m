function snd = chordSound(voices, duration, Fs)
    nSamples = round(duration * Fs);
    time = ((1:nSamples)/Fs)';
    snd = zeros(nSamples, 1);
    
    %% chord synthesis
    zeroFreq = 220; % Hz
    for i = 1:length(voices)
        freq = zeroFreq * 2^(voices(i)/12);
        snd = snd + waveShape(freq*time + rand);
    end
    
    %% levelling
    snd = 0.8 * snd / max(snd);
    
    %% fade in/out
    fadeDur = 200; %ms
    nFade = round((fadeDur/1000)*Fs);
    fadeVal = (sqrt((0:(nFade-1))/(nFade-1)))';
    snd(1:nFade) = snd(1:nFade).*fadeVal;
    snd(end-nFade+1:end) = snd(end-nFade+1:end).*flip(fadeVal);
    
    %%
    function f = waveShape(t)
        f = sin(2*pi*t);

%         t = t - floor(t);
%         f = -1 + 2*gt(t, 0.5);
    end
end