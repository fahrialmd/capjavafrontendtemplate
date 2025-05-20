namespace com.fahrialmd.bookstore;

using {com.fahrialmd.bookstore as bookstore} from '../index';
using {sap.common.CodeList} from '@sap/cds/common';


type rating_enum : bookstore.rating enum {
    Best = 5;
    Good = 4;
    Avg = 3;
    Poor = 2;
    Worst = 1;
}

entity status : CodeList {
    key code : String(1) enum {
            soldOut = 'O';
            onSelling = 'A';
            Outdated = 'X';
        } default 'O';
}
