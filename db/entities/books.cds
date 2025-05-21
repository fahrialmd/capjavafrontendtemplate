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
    reviews      : Association to many bookstore.Reviews
                       on reviews.book = $self;
    isReviewable : bookstore.Tech_Boolean not null default true;
    status       : Association to bookstore.status @readonly;
}

// input validation
annotate Books with {
    title @mandatory;
    stock @mandatory;
}
