FROM harryjubb/openbabel-python:python2.7.15
LABEL maintainer="Harry Jubb<hj4@sanger.ac.uk>"

RUN mkdir /arpeggio
WORKDIR /arpeggio

COPY requirements.txt /arpeggio
RUN pip install --no-cache-dir -r requirements.txt

COPY config.py /arpeggio
COPY arpeggio.py /arpeggio
COPY show_contacts.py /arpeggio
