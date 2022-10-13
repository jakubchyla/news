#! /bin/sh

main()
{
    if [ -z "$KINDLE_MAIL" ]; then
        printf "set KINDLE_MAIL variable\n" \
               "exiting...\n"
    fi
    if [ -z "$MAIL_SERVER" ]; then
        MAIL_SERVER="mail:25"
        printf "MAIL_SERVER not specified, setting to default: $MAIL_SERVER\n"
    fi
    if [ -z "$RECIPE_DIR" ]; then
        RECIPE_DIR="$(dirname "$(realpath "$0")")/recipes"
        printf "RECIPE_DIR not specified, setting to default: $RECIPE_DIR\n"
    fi
    if [ -z "$OUTPUT_DIR" ]; then
        OUTPUT_DIR="$(dirname "$(realpath "$0")")/output"
        printf "OUTPUT_DIR not specified, setting to default: $OUTPUT_DIR\n"
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
