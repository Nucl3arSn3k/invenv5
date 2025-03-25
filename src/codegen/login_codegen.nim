{.emit: """
#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <string.h>
#include <curl/curl.h>
#include <math.h>
""".}

proc loginhandle*(username, password, url: cstring): clong {.exportc, dynlib.} =
  {.emit: """
  printf("Username:%s \\n", `username`);
  printf("Password:%s \\n", `password`);
  long http_code = 0;
  CURL *curl = curl_easy_init();
  CURLcode ret;
  if (curl)
  {
      struct curl_slist *chunk = NULL;
      char *form_url;
      int re2s = asprintf(&form_url, "Referer: %s", `url`);
      if (re2s == -1) perror("error with printf");
      
      chunk = curl_slist_append(chunk, form_url);
      chunk = curl_slist_append(chunk, "Content-Type: application/x-www-form-urlencoded");
      chunk = curl_slist_append(chunk, "Accept: response/json");

      char *char_array_fin;
      int res = asprintf(&char_array_fin, "user=%s&password=%s", `username`, `password`);
      if (res == -1) perror("error with printf");

      curl_easy_setopt(curl, CURLOPT_URL, `url`);
      curl_easy_setopt(curl, CURLOPT_HTTPHEADER, chunk);
      curl_easy_setopt(curl, CURLOPT_POST, 1L);
      curl_easy_setopt(curl, CURLOPT_POSTFIELDS, char_array_fin);
      
      char errbuf[CURL_ERROR_SIZE];
      curl_easy_setopt(curl, CURLOPT_ERRORBUFFER, errbuf);
      curl_easy_setopt(curl, CURLOPT_VERBOSE, 1L);
      ret = curl_easy_perform(curl);
      printf("CURL return code: %d\\n", ret);
      
      curl_easy_getinfo(curl, CURLINFO_RESPONSE_CODE, &http_code);
      printf("HTTP Status code is: %ld \\n",http_code);
      if (ret != CURLE_OK) {
          fprintf(stderr, "CURL error %s\\n", errbuf);
      } else {
          fprintf(stderr, "CURL error: %s\\n", curl_easy_strerror(ret));
      }

      curl_easy_cleanup(curl);
  }
  curl_global_cleanup();
  return http_code;
""".}