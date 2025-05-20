using {com.fahrialmd.bookstore as bookstore} from '../db/index';

@path: 'books'
service BookService {
  entity Books   as projection on bookstore.Books
    actions {
      action addReview(rating : bookstore.rating_enum, title : bookstore.title, descr : bookstore.description) returns Reviews;
    };

  entity Reviews as projection on bookstore.Reviews;
}
