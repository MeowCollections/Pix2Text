predict:
	p2t predict -l en,ch_sim -a mfd -t yolov7_tiny -i docs/examples/mixed.jpg --save-analysis-res tmp-output.jpg
#	p2t predict -l en,ch_sim --text-ocr-config '{"rec_model_name": "doc-densenet_lite_666-gru_large"}' \
#	 --use-analyzer -a mfd -t yolov7 --resized-shape 768 \
#	 --analyzer-model-fp ~/.cnstd/1.2/analysis/mfd-yolov7-epoch224-20230613.pt \
#	 --latex-ocr-model-fp ~/.pix2text/formula/p2t-mfr-20230702.pth \
#	 -i docs/examples/mixed.jpg --save-analysis-res tmp-output.jpg
#	p2t predict -l vi \
#	 --use-analyzer -a mfd -t yolov7 --resized-shape 768 \
#	 --analyzer-model-fp ~/.cnstd/1.2/analysis/mfd-yolov7-epoch224-20230613.pt \
#	 --latex-ocr-model-fp ~/.pix2text/formula/p2t-mfr-20230702.pth \
#	 -i docs/examples/vietnamese.jpg --save-analysis-res tmp-output.jpg
#	p2t predict -l en,ch_tra \
#	 --use-analyzer -a mfd -t yolov7 --resized-shape 768 \
#	 --analyzer-model-fp ~/.cnstd/1.2/analysis/mfd-yolov7-epoch224-20230613.pt \
#	 --latex-ocr-model-fp ~/.pix2text/formula/p2t-mfr-20230702.pth --rec-kwargs '{"det_bbox_max_expand_ratio": 0}'\
#	 -i docs/examples/ch_tra7.jpg --save-analysis-res tmp-output.jpg

evaluate-mfr:
	p2t evaluate -l en,ch_sim --mfd-config '{"model_name": "mfd"}' \
	--formula-ocr-config '{"model_name":"mfr-1.5","model_backend":"onnx"}' \
	--text-ocr-config '{"rec_model_name": "doc-densenet_lite_666-gru_large"}' \
	--resized-shape 768 --auto-line-break --file-type formula \
	--max-samples 50 --prefix-img-dir data \
	-i data/exported_call_events_with_images.json -o data/exported_cer_mfr1.0.json \
	--output-excel data/exported_cer_mfr1.0.xls --output-html data/exported_cer_mfr1.0.html
	

package:
	rm -rf build
	python setup.py sdist bdist_wheel

VERSION := $(shell sed -n "s/^__version__ = '\(.*\)'/\1/p" pix2text/__version__.py)
upload:
	python -m twine upload  dist/pix2text-$(VERSION)* --verbose

# 开启 OCR HTTP 服务
serve:
	p2t serve -l en,ch_sim -a mfd -t yolov7 --analyzer-model-fp ~/.cnstd/1.2/analysis/mfd-yolov7-epoch224-20230613.pt --formula-ocr-config '{"model_name":"mfr-pro-1.5","model_backend":"onnx"}' --text-ocr-config '{"rec_model_name": "doc-densenet_lite_666-gru_large"}'

docker-build:
	docker build -t breezedeus/pix2text:v$(VERSION) .

.PHONY: package upload serve daemon
