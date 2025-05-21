using {com.fahrialmd.bookstore as bookstore} from '../db/index';

@path: 'browser'
service BrowserService {

    @readonly
    entity Books   as
        projection on bookstore.Books
        excluding {
            createdBy,
            modifiedBy
        }
        actions {
            action addReview(rating : bookstore.rating_enum, title : bookstore.title, descr : bookstore.description) returns Reviews;
        };

    @readonly
    entity Reviews as projection on bookstore.Reviews;

}
