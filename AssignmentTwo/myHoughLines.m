function [lines] = myHoughLines(bw, theta, rho, peaks)
    lines = zeros(size(peaks, 1), 4);

    for index = 1:size(peaks, 1)
        %Get peak theta, rho
        T = theta(peaks(index,2));
        R = rho(peaks(index, 1));

        %Convert polar to cartesian
        xs = R .* cos(pi .* (T) ./ 180);
        ys = R .* sin(pi .* (T) ./ 180);
        m = tan(pi.*(T + 90) ./ 180);
        c = ys - (m .* xs);

        %Calculate line points
        xs = 1:size(bw,2);
        ys = round(c + (m * xs));
        xs = xs((ys >= 1) & (ys <= size(bw, 1)));
        ys = ys((ys >= 1) & (ys <= size(bw, 1)));

        %Find longest line in points
        whites = bw(sub2ind(size(bw), ys, xs));
        start = find(whites, 1, 'first');
        finish = start;
        while whites(finish)
            finish = finish + 1;
        end

        lines(index,:) = [xs(start) ys(start) xs(finish - 1) ys(finish - 1)];
    end
end