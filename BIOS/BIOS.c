int panicMode; int osAddress; int osLength;
int post(void){
    int i;
    i = 1;

    osAddress = 0;
    osLength = 256;
    return i;
}

void biosPanic(){
    panicMode = 1;
}

int loadOs(int baseAddress, int size){
    int wordIndex;
    int instrBaseAddress;

    wordIndex = 0;
    instrBaseAddress = 0;
    while(wordIndex < size){
        swLoadWord(baseAddress, wordIndex, instrBaseAddress);
        wordIndex = wordIndex + 1;
    }


}

void main(void){
    int state;

    if(post() < 1){
        state = 9999;
        biosPanic();
    }
    if(loadOs(osAddress, osLength) < 1){
        state = 9998;
        biosPanic();
    }
}