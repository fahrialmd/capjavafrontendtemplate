namespace com.fahrialmd.bookstore;

using {
    cuid,
    managed
} from '@sap/cds/common';

using {com.fahrialmd.bookstore as bookstore} from '../index';

entity Reviews : cuid, managed {
    @cds.odata.ValueList
    book   : Association to bookstore.Books;
    rating : bookstore.rating;
    title  : bookstore.title;
    descr  : bookstore.description;
}

// input validation
annotate Reviews with {
    book   @mandatory  @assert.target;
    rating @assert.range;
    title  @mandatory;
}
