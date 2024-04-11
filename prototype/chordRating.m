function rating = chordRating(voices, findWorst)
    if nargin==1, findWorst = false; end
    zeroFreq = 110; % Hz
    nHarmMin = 10;
    voices = voices - min(voices);
    
    %% construct spectrum up to nHarmMin'th harmonic
    nVoice = length(voices);
    freq = zeros(nVoice, 1);
    for iVoice=1:nVoice
        freq(iVoice) = zeroFreq * 2^(voices(iVoice)/12); % Hz
    end
    nHarmMax = floor(max(freq)*nHarmMin / min(freq));
    spctr = zeros(nHarmMax*nVoice,1);
    nL = 0;
    for iVoice=1:nVoice
        nHarmCurr = floor(max(freq)*nHarmMin / freq(iVoice));
        spctr(nL+1:nL+nHarmCurr) = freq(iVoice)*(1:nHarmCurr)';
        nL = nL+nHarmCurr;
    end
    spctr = spctr(1:nL);
    
    %% calculate number of independent spectral lines
    maxBeatFreq = 5; % Hz
    nLraw = nL;
    spctr = sort(spctr, 'ascend');
    
    iL = 1;
    while iL<nL
        if 0.5*(spctr(iL+1)-spctr(iL)) < maxBeatFreq % then we think these spectral lines are heard as one beating
            spctr(iL) = 0.5*(spctr(iL+1)+spctr(iL));
            spctr(iL+1) = [];
            nL = nL-1;
        else
            iL = iL+1;
        end
    end
    
    rating = (1 - (nL / nLraw))/(1 - 1/nVoice); % 1 for perfect harmonics, 0 for no overlapping
    if findWorst, rating = - rating; end
    
end

