function [MeanVals, MedianVals, ModeVals, SkewVals, KurtosisVals, TMeanVals, RMSVals, RSqrOfTotalGaussian, RSqrOfModeGaussian, FitInfo, ProblemRegions, WindowHistFit] =get_DistributionCharacterizationSD12(myDataRaw,myDataHist)

[a b c]=size(myDataRaw);
MeanVals=NaN(size(myDataRaw));
MedianVals=NaN(size(myDataRaw));
ModeVals=NaN(size(myDataRaw));
SkewVals=NaN(size(myDataRaw));
KurtosisVals=NaN(size(myDataRaw));
% GMeanVals=NaN(size(myDataRaw));
% HMeanVals=NaN(size(myDataRaw));
TMeanVals=NaN(size(myDataRaw));
RMSVals=NaN(size(myDataRaw));

ProblemRegions=0;

for i=1:1:a
    i
    NumOfProblemRegions=0;
    
    for j=1:1:b
        j
        for k=1:1:c
            k
            % finding mean and median is trivial
            Data=cell2mat(myDataRaw(i,j,k));
            Data(isnan(Data))=0;
            Data=nonzeros(Data);
            MeanVals(i,j,k)=mean(Data);
            MedianVals(i,j,k)=median(Data);
            SkewVals(i,j,k)=skewness(Data);
            KurtosisVals(i,j,k)=kurtosis(Data);
            %             GMeanVals(i,j,k)=geomean(Data);
            %             HMeanVals(i,j,k)=harmmean(Data);
            TMeanVals(i,j,k)=trimmean(Data,10);
            RMSVals(i,j,k)=rms(Data);
            
            % now finding the mode...
            clearvars temp X
            temp=cell2mat(myDataHist(i,j,k));
            
            if isempty(temp)
                NumOfProblemRegions=1+NumOfProblemRegions;
                ProblemRegions=[ProblemRegions, k];
            else
                X(:,1)=temp(:,2);
                X(:,2)=temp(:,1);
                
                [M,I]=max(X(:,2));
                signal=X;
                center=X(I,1);
                
                if mean(Data)>10
                    window=200;
                else
                    window=0.1;
                end
                
                NumPeaks=1;
                peakshape=0;
                extra=0;
                NumTrials=5;
                
                [FitResults, GOF,~,~,~,xi,yi]=peakfit(signal,center,window,NumPeaks,peakshape,extra,NumTrials);
                FitInfo(i,j,k)={[FitResults]};
                RSqrOfModeGaussian(i,j,k)=GOF(1,2);
                
                [M,I]=max(yi);
                ModeVals(i,j,k)=xi(I); % Mode finally!
                
                HistData(:,1)=xi(:);
                HistData(:,2)=yi(:);
                WindowHistFit{i,j,k}=HistData;
                
                % Now we quantify the gaussian-ness of the whole
                % distribution
                center=0;
                window=0;
                NumPeaks=1;
                peakshape=0;
                extra=0;
                NumTrials=5;
%                 [~,GOF,~,~,~,~,~]=peakfit(signal,center,window,NumPeaks,peakshape,extra,NumTrials);
                [~,GOF,~,~,~,~,~]=peakfit(signal);
                RSqrOfTotalGaussian(i,j,k)=GOF(1,2);
                
            end
            NumOfProblemRegions;
        end
        
    end
end

end