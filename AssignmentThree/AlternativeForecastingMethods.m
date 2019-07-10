function [pointNAhead] = linearForecastN(self, N)
    nPointsAgo = self.theTrack(self.theTrackIndex - N, :);
    diff = self.theTrack(self.theTrackIndex, :) - nPointsAgo;
    pointNAhead = self.theTrack(self.theTrackIndex, :) + diff;
end

function [pointNAhead] = momentumForecastN(self, N, lookBackM)
    history = self.theTrack(self.theTrackIndex-N-lookBackM+1:self.theTrackIndex - N, :);

    %Linear interpolate M points
    diffs = self.theTrack(self.theTrackIndex, :) - history;
    normalisedDiffs = diffs ./ linspace((lookBackM + N)/N, 1, lookBackM)';
    forecasts = self.theTrack(self.theTrackIndex, :) + normalisedDiffs;

    %Calculate weighted average
    adjustedForecasts = forecasts - forecasts(end, :);
    forecastWeights = 1 .^ linspace(lookBackM - 1, 0, lookBackM)';
    weightedForecasts = adjustedForecasts .* forecastWeights;

    pointNAhead = round(forecasts(end, :) + mean(weightedForecasts(1:end-1, :)));
end