FROM mongo
RUN mkdir /config
WORKDIR /config
COPY waitForIt.sh .
COPY mongoSetup.sh .
RUN chmod +x /config/waitForIt.sh
RUN chmod +x /config/mongoSetup.sh
CMD [ "bash", "-c", "/config/waitForIt.sh localmongo1:27017 -- /config/mongoSetup.sh"]