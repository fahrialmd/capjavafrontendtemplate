using from '../../srv/books-service';
using from '../../srv/browser-service';

annotate BookService.Books with {
    ID       @UI.Hidden  @UI.HiddenFilter;
    isbn     @Common.FieldControl : #ReadOnly;
    descr    @UI.MultiLineText    : true;
    price    @Measures.ISOCurrency: currency.code;
    // currency @UI.Hidden;
    reviews  @UI.Hidden  @UI.HiddenFilter;
} actions {
    @(
        Common.SideEffects             : {
            TargetProperties: ['_it/rating'],
            TargetEntities  : [
                _it,
                _it.reviews
            ]
        },
        cds.odata.bindingparameter.name: '_it',
        Core.OperationAvailable        : _it.isReviewable
    )
    addReview(rating  @mandatory,  title  @mandatory,  descr  @mandatory  )
};

annotate BookService.Reviews with {
    descr @UI.MultiLineText: true;
};

annotate BookService.Books.texts with {
    descr @UI.MultiLineText: true;
};


annotate BrowserService.Books with {
    ID     @UI.Hidden  @UI.HiddenFilter;
    isbn   @Common.FieldControl : #ReadOnly;
    descr  @UI.MultiLineText    : true;
    price  @Measures.ISOCurrency: currency_code;
    rating @readonly;
};

annotate BrowserService.Reviews with {
    descr @UI.MultiLineText: true;
};
