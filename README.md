# WebScrap

Simple web scrap for https://www.e-drpciv.ro/ Questions and answers
This is needed for my driving license so I thought it would be great to have all the question in one place


It will owerwrite the test.csv every time when run.
The test.csv and the test_output folder should be created previously.

Use the following command to run from iex
WebScrap.create_csv("https://www.e-drpciv.ro/intrebare/1")

## Todo:
- [ ] Phoenix app to control inputs running etc
- [ ] create the folders and files dynamically based on input
- [ ] use google sheets instead of CSV
- [ ] use the result to create an automatic answering app
- [ ] load the images as well as currently the question based on images doesn't help (should be challenging with the answering app to match the image)


