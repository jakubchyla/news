#! /bin/sh

main()
{
    if [ -z "$KINDLE_MAIL" ]; then
        printf "set KINDLE_MAIL variable\n" \
               "exiting...\n"
    fi
    if [ -z "$MAIL_SERVER" ]; then
        printf "MAIL_SERVER not specified, setting to default \"mail:25""\n"
        MAIL_SERVER="mail:25"
    fi
    if [ -z "$RECIPE_DIR" ]; then
        printf "RECIPE_DIR not specified, setting to default \"/news/recipes""\n"
        RECIPE_DIR="/news/recipes"
    fi
    if [ -z "$OUTPUT_DIR" ]; then
        printf "OUTPUT_DIR not specified, setting to default \"/news_output""\n"
        OUTPUT_DIR="/news_output"
    fi
    get_news
    send_news
}

get_news()
{
    for RECIPE in $(find "$RECIPE_DIR" -maxdepth 1 -name "*.recipe"); do
        OUTPUT_FILE="$OUTPUT_DIR/$(basename $RECIPE | sed -e 's/\.recipe/.epub/')"
        ebook-convert $RECIPE "$OUTPUT_FILE"
    done
}
send_news()
{
    for file in $(find "$OUTPUT_DIR" -maxdepth 1 -name "*.epub"); do
        ATTACHMENTS="$ATTACHMENTS --attach=$file "
    done
    printf "news" | s-nail --subject="Daily News" \
         $ATTACHMENTS \
         -S mta=smtp://$MAIL_SERVER \
         $KINDLE_MAIL
}

main $@