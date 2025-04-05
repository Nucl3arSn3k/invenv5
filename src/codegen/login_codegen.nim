# Modified approach 2 that will compile correctly

# For C includes, we need to use the emit pragma at the top level of the module
{.emit: """
#include <stdio.h>
#include <stdlib.h>
#include <curl/curl.h>
""".}

# CURL initialization as a separate template
template initCurl() =
  {.emit: """
  CURL *curl = curl_easy_init();
  CURLcode ret;
  long http_code = 0;
  """.}

# Template for setting up headers
template setupHeaders() =
  {.emit: """
  struct curl_slist *chunk = NULL;
  chunk = curl_slist_append(chunk, "Content-Type: application/x-www-form-urlencoded");
  chunk = curl_slist_append(chunk, "Accept: response/json");
  """.}

# Template for configuring the request with specific variables
template configureRequest(url, username, password: untyped) =
  {.emit: """
  // Format payload
  char *payload;
  asprintf(&payload, "user=%s&password=%s", `username`, `password`);
  
  // Configure request
  curl_easy_setopt(curl, CURLOPT_URL, `url`);
  curl_easy_setopt(curl, CURLOPT_HTTPHEADER, chunk);
  curl_easy_setopt(curl, CURLOPT_POST, 1L);
  curl_easy_setopt(curl, CURLOPT_POSTFIELDS, payload);
  curl_easy_setopt(curl, CURLOPT_VERBOSE, 1L);
  """.}

# Template for executing the request
template executeRequest() =
  {.emit: """
  // Execute request
  ret = curl_easy_perform(curl);
  curl_easy_getinfo(curl, CURLINFO_RESPONSE_CODE, &http_code);
  """.}

# Template for cleanup
template cleanupRequest() =
  {.emit: """
  // Cleanup
  free(payload);
  curl_slist_free_all(chunk);
  curl_easy_cleanup(curl);
  """.}

# Main login handler that combines all the pieces
proc loginhandle*(username, password, url: cstring): clong {.exportc, dynlib.} =
  # Initialize CURL
  initCurl()
  
  # Setup headers
  setupHeaders()
  
  # Configure the request with user data
  configureRequest(url, username, password)
  
  # Execute the request
  executeRequest()
  
  # Cleanup
  cleanupRequest()
  
  # Return the HTTP code
  {.emit: "return http_code;".}