package com.fahrialmd.bookstore.handlers;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.math.BigDecimal;
import java.util.Arrays;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import com.fahrialmd.bookstore.common.MessageKeys;
import com.fahrialmd.bookstore.common.RatingCalculator;
import com.sap.cds.Result;
import com.sap.cds.ql.Insert;
import com.sap.cds.ql.Update;
import com.sap.cds.ql.cqn.AnalysisResult;
import com.sap.cds.ql.cqn.CqnAnalyzer;
import com.sap.cds.ql.cqn.CqnInsert;
import com.sap.cds.ql.cqn.CqnSelect;
import com.sap.cds.reflect.CdsModel;
import com.sap.cds.services.ErrorStatuses;
import com.sap.cds.services.ServiceException;
import com.sap.cds.services.cds.CdsUpdateEventContext;
import com.sap.cds.services.cds.CqnService;
import com.sap.cds.services.handler.EventHandler;
import com.sap.cds.services.handler.annotations.After;
import com.sap.cds.services.handler.annotations.Before;
import com.sap.cds.services.handler.annotations.On;
import com.sap.cds.services.handler.annotations.ServiceName;
import com.sap.cds.services.persistence.PersistenceService;

import cds.gen.bookservice.AddReviewContext;
import cds.gen.bookservice.BookService_;
import cds.gen.bookservice.Books_;
import cds.gen.bookservice.Reviews;
import cds.gen.bookservice.Reviews_;
import cds.gen.bookservice.Upload;
import cds.gen.bookservice.Upload_;

import cds.gen.com.fahrialmd.bookstore.Books;

@Component
@ServiceName(BookService_.CDS_NAME)
public class BooksServiceHandler implements EventHandler {

    @Autowired
    private CdsModel model;

    @Autowired
    private PersistenceService db;

    @Autowired
    private RatingCalculator ratingCalculator;

    @On(event = AddReviewContext.CDS_NAME)
    public void onAddReview(AddReviewContext context) {

        String bookId = (String) CqnAnalyzer.create(model).analyze(context.getCqn()).targetKeys().get(Books.ID);

        Reviews review = Reviews.create();
        review.setBookId(bookId);
        review.setRating(context.getRating());
        review.setTitle(context.getTitle());
        review.setDescr(context.getDescr());

        context.setResult(db.run(Insert.into(Reviews_.CDS_NAME).entry(review)).single(Reviews.class));
    }

    @After(event = AddReviewContext.CDS_NAME)
    public void afterAddedReview(AddReviewContext context) {
        String bookId = context.getResult().getBookId();
        ratingCalculator.setBookRating(bookId);
        setBookUnreviewable(bookId, false);
    }

    private void setBookUnreviewable(String bookId, Boolean reviewable) {
        Books book = Books.create();
        book.setId(bookId);
        db.run(Update.entity(BookService_.BOOKS, b -> b.matching(book)).data(Books.IS_REVIEWABLE,
                reviewable));
    }

    @Before(event = CqnService.EVENT_READ, entity = Books_.CDS_NAME)
    public void ininBooksBeforeRead() {
        ratingCalculator.initBookRatings();
    }

    @Before(event = CqnService.EVENT_CREATE, entity = Books_.CDS_NAME)
    public void initBookBeforeCreate(Books book) {
        book.setStatusCode("A");
        book.setIsbn(getNextIsbn());
    }

    private String getNextIsbn() {
        String isbnPrefix = "Win-";
        String isbnSuffix = "1000000000";
        return isbnPrefix + isbnSuffix;
    }

    @On(event = CqnService.EVENT_CREATE, entity = Books_.CDS_NAME)
    public void changeBookOnCreate(Books book) {
        if (book.getStock() == 0) {
            book.setStatusCode("O");
        }
    }

    @On(event = CqnService.EVENT_UPDATE, entity = Books_.CDS_NAME)
    public void changeBookOnUpdate(Books book) {
        book.setStatusCode(book.getStock() == 0 ? "O" : "A");
    }

    @On(entity = Upload_.CDS_NAME, event = CqnService.EVENT_READ)
    public Upload getUploadSingleton() {
        return Upload.create();
    }

    @On
    public void addBooksViaCsv(CdsUpdateEventContext context, Upload upload) {
        InputStream is = upload.getCsv();
        if (is != null) {
            try (BufferedReader br = new BufferedReader(new InputStreamReader(is))) {
                br.lines().skip(1).forEach((line) -> {
                    String[] p = line.split(";");
                    Books book = Books.create();
                    book.setId(p[0]);
                    book.setTitle(p[1]);
                    book.setDescr(p[2]);
                    book.setStock(Integer.valueOf(p[3]).intValue());
                    book.setPrice(BigDecimal.valueOf(Double.valueOf(p[4])));
                    book.setCurrencyCode(p[5]);
                    book.setRating(BigDecimal.valueOf(Double.valueOf(p[6])));
                    book.setIsbn(p[7]);
                    book.setStatusCode(p[8]);

                    // separate transaction per line
                    context.getCdsRuntime().changeSetContext().run(ctx -> {
                        db.run(Insert.into(BookService_.BOOKS).entry(book));
                    });
                });
            } catch (IOException e) {
                throw new ServiceException(ErrorStatuses.SERVER_ERROR, MessageKeys.BOOK_IMPORT_FAILED, e);
            } catch (IndexOutOfBoundsException e) {
                throw new ServiceException(ErrorStatuses.SERVER_ERROR, MessageKeys.BOOK_IMPORT_INVALID_CSV, e);
            }
        }
        context.setResult(Arrays.asList(upload));
    }
}
