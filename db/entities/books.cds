namespace com.fahrialmd.bookstore;

using {
    cuid,
    Currency,
    managed
} from '@sap/cds/common';

using {com.fahrialmd.bookstore as bookstore} from '../index';

@fiori.draft.enabled
entity Books : cuid, managed {
    title        : localized bookstore.title;
    descr        : localized bookstore.description;
    stock        : Integer;
    price        : bookstore.price;
    currency     : Currency;
    rating       : bookstore.rating;
    review       : Association to many bookstore.Reviews;
    isReviewable : bookstore.Tech_Boolean not null default true;
}

// input validation
annotate Books with {
    title @mandatory;
    stock @mandatory;
}
