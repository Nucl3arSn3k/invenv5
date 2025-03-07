#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <curl/curl.h>

void loginhandle(const char* username,const char* password,const char* url){
    
    //FILE* logfile = fopen("login_out.log","a");
    printf("Username:%s \n",username);
    printf("Password:%s \n",password);
    CURL *curl = curl_easy_init();
    if (curl){
        curl_easy_setopt(curl,CURLOPT_URL,url); //Sets URL

        struct curl_slist *chunk = NULL; //header options

        chunk = curl_slist_append(chunk, "Referer: login_url");
        chunk = curl_slist_append(chunk, "Content-Type: application/x-www-form-urlencoded");
        chunk = curl_slist_append(chunk, "Accept: response/json");

        curl_easy_setopt(curl, CURLOPT_HTTPHEADER, chunk); //Make custom header

    }


    
}