# Flicker_API
This is the code I wrote to retrieve Flicker posts using R and the package "FlickrAPI".
The code build on a geographic reference for Glasgow and a 100 miles buffer, the code search for a vocabolary of words, which also include parks names (saved as a separate file, "names.Rda").

The code, go through every word of the dictionary and saves the all timeline starting from the older and most recents posts at the same time. The files are saved in the setted directory. To make this work, you will need to get your API keys values from Flicker. 

The files saved will be a .rda and .xlxs (for faster inspection). The retrieval of the words in the vocabulary will progress in an alphabetical order, since the API sometimes disconnect, that way it will be easier to restart the retrieval.

The process use a sophisticated code, with optimised procedure. It is resistant to not saving empty retrievals and avoid lopping on retrieving the same Flicker data - it will in fact stop after some pages of non new data. There is an issue though that seems to be mostly related to the API itself, that it could not retrieve more than 8k posts for each usage for each word. That's why we suggest a continuous usage 

Enjoy the usage. 
