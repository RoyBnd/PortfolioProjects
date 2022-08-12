# Creating connection to Moviedb with api key
import requests
import pprint 
import pandas as pd
# Copy the api key from movidedb.org 
api_key = "42c4b2963ec983cebc49a7280******"

# Getting End point url from the site
"""
Endpoint 
https://api.themoviedb.org/3/movie/550?api_key=42c4b2963ec983cebc49a7280******

"""
# Set parms
movie_id = 500
api_version = 3 
api_base_url = f"https://api.themoviedb.org/{api_version}"
endpoint_path = f"/movie/{movie_id}" # we can use f method to make it more flexibale
endpoint = f"{api_base_url}{endpoint_path}?api_key={api_key}" # create the full url 

# r = requests.get(endpoint)
# print(r.status_code)
# print(r.text)

# Search by movie name

api_base_url = f"https://api.themoviedb.org/{api_version}"
endpoint_path = f"/search/movie" 
search_query = "The Matrix"
endpoint = f"{api_base_url}{endpoint_path}?api_key={api_key}&query={search_query}" 
r = requests.get(endpoint)
print(r.status_code)
#pprint.pprint(r.json()) # using pprint library to print the data in more readable way.

# Find movie ids using movie name.
if r.status_code in range(200,299): # Check that we get sucsess code before we start.
    data = r.json()
    results = data['results']
    if len(results) > 0:
        #print(results[0].keys()) # print the headers to check if there is id header.
        movie_ids = set() # set helps us to print only unique values.
        for result in results:
            _id = result['id'] # We use _id and not id because 'id' is in many cases a reserved word in Python.
            #print(result['title'],_id) # print movie titles and id for each one.
            movie_ids.add(_id) # Adding all the unique ids that match the id column.
        #print(list(movie_ids))

# Saving the data into csv file.
output = 'movies.csv'
movies_data = []
for movie_id in movie_ids:
    api_version = 3 
    api_base_url = f"https://api.themoviedb.org/{api_version}"
    endpoint_path = f"/movie/{movie_id}" 
    endpoint = f"{api_base_url}{endpoint_path}?api_key={api_key}" 
    r = requests.get(endpoint) 
    if r.status_code in range(200,299):
        data = r.json()
        movies_data.append(data)

# Creating dataframe 
df = pd.DataFrame(movies_data) 
print(df.head())
df.to_csv(output, index=False) # Saving the df as csv passing: name for the file  and index=False to avoid indexing   

