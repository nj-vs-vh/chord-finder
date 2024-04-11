Fs = 44100;
dur = 4;

jumpProb = 0.5;
jumpRange = 7;

minNote = 0;
maxNote = 12;

currChord = [0 3 7];
nNotes = length(currChord);
chordBufferLength = 4;
chordBuffer = repmat(currChord, 1, chordBufferLength);

% searchRange = -1:0.25:1;
searchRange = -5:5;
deltaStepList = arrangementsWithReturn(searchRange, length(currChord));
nD = size(deltaStepList,1);

findWorst = false;
while 1

    %% looking for step
    rating = zeros(nD,1);
    valid = false(nD,1);
    
    if rand<jumpProb
        deltaStepCurrent = zeros(size(deltaStepList));
        jump = true;
    else
        jump = false;
        deltaStepCurrent = deltaStepList;
    end
    
    for iD = 1:nD
        if jump % generate delta list on the fly
            for iNotes = 1:nNotes
                jumpChord = round(currChord + 2*jumpRange*(rand(1,nNotes)-0.5));
                jumpChord = sort(jumpChord, 'ascend');
                deltaStepCurrent(iD,:) = jumpChord-currChord;
            end
        end
        delta = deltaStepCurrent(iD, :);
        if ~all(eq(delta,0)) && verifyChord(currChord+delta, minNote, maxNote)
            valid(iD) = true;
            rating(iD) = chordRating(currChord+delta, findWorst);
        end
    end
    %% picking valid steps with top rating
    deltaStepCurrent = deltaStepCurrent(valid,:); % pick valid
    rating = rating(valid);
    if isempty(rating), disp('oops'); continue; end
    deltaStepCurrent = deltaStepCurrent(eq(rating, max(rating)), :); % pick top rated
    
    %% picking steps with best correlation
    nDstep = size(deltaStepCurrent,1);
    corrating = zeros(nDstep,1);
    for iD = 1:size(deltaStepCurrent,1)
        chordBufferStep = chordBuffer;
        chordBufferStep(1:nNotes) = chordBufferStep(1:nNotes) + deltaStepCurrent(iD,:);
        corrating(iD) = chordRating(chordBufferStep, false);
    end
    corratingThreshold = 0.5*(max(corrating) + min(corrating));
    deltaStepCurrent = deltaStepCurrent(ge(corrating, corratingThreshold), :);
    deltaStepCurrent = deltaStepCurrent(randi(size(deltaStepCurrent,1)), :); % pick random at least
    
    chordBuffer(1:nNotes) = chordBuffer(1:nNotes) + deltaStepCurrent;
    chordBuffer(nNotes+1:end) = chordBuffer(1:end-nNotes);
    
    %% check if step is good and go
    currRating = chordRating(currChord, findWorst);
    sound(chordSound(currChord, dur, Fs), Fs);
    fprintf('chord %s, rating %f\n', num2str(currChord), currRating);
    pause(dur);
    
    if max(rating) <= currRating, findWorst = ~findWorst; end
    currChord = currChord+deltaStepCurrent;

end

function tf = verifyChord(voices, minNote, maxNote)
    tf = true;
    % check for similar voices
    for i=1:length(voices)
        if voices(i)<minNote || voices(i)>maxNote, tf = false; return; end
        if any(eq(voices([1:i-1 i+1:end]), voices(i))), tf = false; return; end
    end
    % check for correct voice order
    if ~all(eq(sort(voices, 'ascend'),voices)), tf = false; return; end
end