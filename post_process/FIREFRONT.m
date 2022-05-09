function X=FIREFRONT(PHIP, EMBER_SOURCE, delX)
IX0 = ceil(EMBER_SOURCE/delX);
FIND1 = PHIP(1:end-1).*PHIP(2:end);
FIND2 = find(FIND1<0);

IXmin=FIND2(abs(FIND2-IX0) == min(abs(FIND2-IX0)));
X = (IXmin(1)+0.5)*delX;