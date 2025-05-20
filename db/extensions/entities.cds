using {com.fahrialmd.bookstore as bookstore} from '../index';

extend bookstore.Books with {
    isbn : bookstore.ISBN;
}

// input validation
annotate bookstore.Books with {
    isbn @mandatory;
}
