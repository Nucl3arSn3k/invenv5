#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <string.h>
#include <curl/curl.h>
#include <math.h>
void loginhandle(const char *username, const char *password, const char *url)
{

    printf("Username:%s \n", username);
    printf("Password:%s \n", password);

    CURL *curl = curl_easy_init();
    CURLcode ret;
    if (curl)
    {

        struct curl_slist *chunk = NULL; // header options
        char *form_url;
        int re2s = asprintf(&form_url, "Referer: %s", url);

        if (re2s == -1)
        {
            perror("error with printf");
        };

        chunk = curl_slist_append(chunk, form_url);
        chunk = curl_slist_append(chunk, "Content-Type: application/x-www-form-urlencoded");
        chunk = curl_slist_append(chunk, "Accept: response/json");

        char *char_array_fin; // should safetly alloc from asprintf
        int res = asprintf(&char_array_fin, "user=%s&password=%s", username, password);

        if (res == -1)
        {
            perror("error with printf");
        };

        curl_easy_setopt(curl, CURLOPT_URL, url);                   // Sets URL
        curl_easy_setopt(curl, CURLOPT_HTTPHEADER, chunk);          // Make custom header
        curl_easy_setopt(curl, CURLOPT_POST, 1L);                   // Set post to yes
        curl_easy_setopt(curl, CURLOPT_POSTFIELDS, char_array_fin); // Set fields
        char errbuf[CURL_ERROR_SIZE];
        curl_easy_setopt(curl, CURLOPT_ERRORBUFFER, errbuf);
        curl_easy_setopt(curl, CURLOPT_VERBOSE, 1L);
        ret = curl_easy_perform(curl); // preform request
        if (ret != CURLE_OK)
        {
            fprintf(stderr, "CURL error %s\n", errbuf);
        }
        else
        {
            fprintf(stderr, "CURL error: %s\n", curl_easy_strerror(res));
        }
        // printf()
        curl_easy_cleanup(curl); // Need json lib to handle return
    }
    curl_global_cleanup();
}