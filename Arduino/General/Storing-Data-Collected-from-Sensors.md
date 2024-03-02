# Storing Data Collected from Sensors
In the previous two chapters, we learned how to collect data from various sensors. However, the best we have done is display the information on a screen. It’s a waste to collect all of that data and not store it. Let’s look at how we can store the data that we are collecting. By the end of this chapter, you will know how to store data in files and various file formats that are in common use, set up a database, and write queries to read data out of a database. The data that you store will be useful for analysis in the future, usually by data analysts. For example, if you collect and store temperature and humidity data from different weather stations over a certain period, then that data can be used to analyze weather patterns.

In this chapter, we are going to cover the following main topics:

    Storing data
    Working with flat files
    Working with databases

We’ll start by listing what you will need to complete this chapter.
# Technical requirements
You will require the following to complete this chapter:

    The Arduino IDE
    Arduino MKR WiFi 1010
    A micro-USB cable
    Arduino MKR ENV Shield or MKR IoT Carrier
    A micro-SD card
    An SD card reader
    A Raspberry Pi 3 or 4, or a virtual machine

If you have got everything you need, then let’s proceed to collect and store some data.

The source code for this chapter can be found in this book’s GitHub repository: https://github.com/securetorobert/Arduino-Data-Communications/tree/main/chapter-4/.

# Storing data