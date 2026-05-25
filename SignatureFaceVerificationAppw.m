classdef SignatureFaceVerificationApp < matlab.apps.AppBase

    properties (Access = public)
        UIFigure                   matlab.ui.Figure
        LoadStoredSignatureButton matlab.ui.control.Button
        LoadInputSignatureButton  matlab.ui.control.Button
        LoadStoredFaceButton      matlab.ui.control.Button
        LoadInputFaceButton       matlab.ui.control.Button
        VerifyButton              matlab.ui.control.Button
        SignatureAxes             matlab.ui.control.UIAxes
        FaceAxes                  matlab.ui.control.UIAxes
        ResultLabel               matlab.ui.control.Label
    end

    properties (Access = private)
        StoredSignatureImage
        InputSignatureImage
        StoredFaceImage
        InputFaceImage
    end

    methods (Access = private)

        function grayImage = im2grayIfNeeded(~, img)
            if size(img, 3) == 3
                grayImage = rgb2gray(img);
            else
                grayImage = img;
            end
        end

        function loadImage(app, target)
            app.ResultLabel.Text = '🖼️ Loading image...';
            [file, path] = uigetfile({'*.jpg;*.jpeg;*.png;*.bmp;*.tif','Image Files'});
            if isequal(file,0)
                app.ResultLabel.Text = '⚠️ Image loading cancelled.';
                return;
            end

            img = imread(fullfile(path, file));

            switch target
                case 'StoredSignature'
                    app.StoredSignatureImage = img;
                    imshow(img, 'Parent', app.SignatureAxes);
                    title(app.SignatureAxes, 'Stored Signature');
                case 'InputSignature'
                    app.InputSignatureImage = img;
                    imshow(img, 'Parent', app.SignatureAxes);
                    title(app.SignatureAxes, 'Input Signature');
                case 'StoredFace'
                    app.StoredFaceImage = img;
                    imshow(img, 'Parent', app.FaceAxes);
                    title(app.FaceAxes, 'Stored Face');
                case 'InputFace'
                    app.InputFaceImage = img;
                    imshow(img, 'Parent', app.FaceAxes);
                    title(app.FaceAxes, 'Input Face');
            end
            app.ResultLabel.Text = '✅ Image loaded successfully.';
        end

        function verify(app)
            try
                % Validation check
                if isempty(app.StoredSignatureImage) || isempty(app.InputSignatureImage) || ...
                   isempty(app.StoredFaceImage) || isempty(app.InputFaceImage)
                    app.ResultLabel.Text = '⚠️ Please load all images before verifying.';
                    return;
                end

                % === Signature Verification ===
                storedSignatureGray = app.im2grayIfNeeded(app.StoredSignatureImage);
                inputSignatureGray  = app.im2grayIfNeeded(app.InputSignatureImage);

                % Resize to fixed size for feature vector consistency
                storedSignatureGray = imresize(storedSignatureGray, [256 256]);
                inputSignatureGray  = imresize(inputSignatureGray, [256 256]);

                storedSigFeatures = extractHOGFeatures(storedSignatureGray);
                inputSigFeatures  = extractHOGFeatures(inputSignatureGray);

                if isempty(storedSigFeatures) || isempty(inputSigFeatures)
                    app.ResultLabel.Text = '⚠️ Signature feature extraction failed.';
                    return;
                end

                sigDistance = pdist2(storedSigFeatures, inputSigFeatures, 'euclidean');
                sigScore = 1 / (1 + sigDistance);  % Higher is better

                % === Face Verification ===
                storedFaceGray = app.im2grayIfNeeded(app.StoredFaceImage);
                inputFaceGray  = app.im2grayIfNeeded(app.InputFaceImage);

                faceDetector = vision.CascadeObjectDetector();
                bbox1 = step(faceDetector, storedFaceGray);
                bbox2 = step(faceDetector, inputFaceGray);

                if isempty(bbox1) || isempty(bbox2)
                    app.ResultLabel.Text = '⚠️ Face detection failed.';
                    return;
                end

                if size(bbox1,1) > 1 || size(bbox2,1) > 1
                    app.ResultLabel.Text = '⚠️ Multiple faces detected. Using first detected face.';
                end

                faceCropped1 = imresize(imcrop(storedFaceGray, bbox1(1,:)), [128 128]);
                faceCropped2 = imresize(imcrop(inputFaceGray, bbox2(1,:)), [128 128]);

                storedFaceFeatures = extractHOGFeatures(faceCropped1);
                inputFaceFeatures  = extractHOGFeatures(faceCropped2);

                faceDistance = pdist2(storedFaceFeatures, inputFaceFeatures, 'euclidean');
                faceScore = 1 / (1 + faceDistance);  % Higher is better

                % === Final Decision ===
                if sigScore > 0.7 && faceScore > 0.7
                    app.ResultLabel.Text = sprintf("✅ Verified!\nSignature Score: %.2f\nFace Score: %.2f", sigScore, faceScore);
                else
                    app.ResultLabel.Text = sprintf("❌ Verification Failed.\nSignature Score: %.2f\nFace Score: %.2f", sigScore, faceScore);
                end

            catch ME
                app.ResultLabel.Text = ['❌ Error: ' ME.message];
            end
        end

        function createComponents(app)
            app.UIFigure = uifigure('Position', [100 100 700 400], 'Name', 'Signature & Face Verification');

            app.LoadStoredSignatureButton = uibutton(app.UIFigure, 'push', ...
                'Position', [20 340 150 30], 'Text', 'Load Stored Signature', ...
                'ButtonPushedFcn', @(~,~)app.loadImage('StoredSignature'));

            app.LoadInputSignatureButton = uibutton(app.UIFigure, 'push', ...
                'Position', [20 300 150 30], 'Text', 'Load Input Signature', ...
                'ButtonPushedFcn', @(~,~)app.loadImage('InputSignature'));

            app.LoadStoredFaceButton = uibutton(app.UIFigure, 'push', ...
                'Position', [20 250 150 30], 'Text', 'Load Stored Face', ...
                'ButtonPushedFcn', @(~,~)app.loadImage('StoredFace'));

            app.LoadInputFaceButton = uibutton(app.UIFigure, 'push', ...
                'Position', [20 210 150 30], 'Text', 'Load Input Face', ...
                'ButtonPushedFcn', @(~,~)app.loadImage('InputFace'));

            app.VerifyButton = uibutton(app.UIFigure, 'push', ...
                'Position', [20 160 150 40], 'Text', 'Verify Identity', ...
                'ButtonPushedFcn', @(~,~)app.verify());

            app.SignatureAxes = uiaxes(app.UIFigure, 'Position', [200 200 220 170]);
            title(app.SignatureAxes, 'Signature');

            app.FaceAxes = uiaxes(app.UIFigure, 'Position', [450 200 220 170]);
            title(app.FaceAxes, 'Face');

            app.ResultLabel = uilabel(app.UIFigure, 'Position', [200 50 500 60], ...
                'FontSize', 14, 'Text', 'Result will appear here...');
        end
    end

    methods (Access = public)

        function app = SignatureFaceVerificationApp()
            createComponents(app);
        end

        function delete(app)
            app.StoredSignatureImage = [];
            app.InputSignatureImage = [];
            app.StoredFaceImage = [];
            app.InputFaceImage = [];
            delete(app.UIFigure);
        end
    end
end
