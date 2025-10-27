from flask import Flask, render_template, request, redirect, url_for, flash, jsonify
import mysql.connector
from datetime import datetime
import os

app = Flask(__name__)
app.secret_key = 'your_secret_key_here'

# Database configuration
DB_CONFIG = {
    'host': 'localhost',
    'user': 'root',
    'password': 'iLovebiryani@123',  # Change this 
    'database': 'movie_ticketing'
}

def get_db_connection():
    return mysql.connector.connect(**DB_CONFIG)

# Home page - Show all movies
@app.route('/')
def index():
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    cursor.execute("""
        SELECT DISTINCT m.movie_id, m.title, m.genre, m.language, m.duration
        FROM Movie m
        INNER JOIN ShowTable st ON m.movie_id = st.movie_id
        WHERE st.showdate >= CURDATE()
        ORDER BY m.title
    """)
    movies = cursor.fetchall()
    cursor.close()
    conn.close()
    return render_template('index.html', movies=movies)

# Show details and available shows
@app.route('/movie/<int:movie_id>')
def movie_details(movie_id):
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    
    # Get movie details
    cursor.execute("SELECT * FROM Movie WHERE movie_id = %s", (movie_id,))
    movie = cursor.fetchone()
    
    # Get available shows
    cursor.execute("""
        SELECT st.show_id, st.showdate, st.show_time,
               t.theatre_name, sc.screen_num
        FROM ShowTable st
        INNER JOIN Screen sc ON st.screen_id = sc.screen_id
        INNER JOIN Theatre t ON sc.theatre_id = t.theatre_id
        WHERE st.movie_id = %s AND st.showdate >= CURDATE()
        ORDER BY st.showdate, st.show_time
    """, (movie_id,))
    shows = cursor.fetchall()
    
    cursor.close()
    conn.close()
    return render_template('movie_details.html', movie=movie, shows=shows)

# Seat selection page
@app.route('/show/<int:show_id>/seats')
def select_seats(show_id):
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    
    # Get show details
    cursor.execute("""
        SELECT st.show_id, st.showdate, st.show_time,
               m.title, t.theatre_name, sc.screen_num, st.screen_id
        FROM ShowTable st
        INNER JOIN Movie m ON st.movie_id = m.movie_id
        INNER JOIN Screen sc ON st.screen_id = sc.screen_id
        INNER JOIN Theatre t ON sc.theatre_id = t.theatre_id
        WHERE st.show_id = %s
    """, (show_id,))
    show = cursor.fetchone()
    
    # Get available seats (seats not already booked for this show)
    cursor.execute("""
        SELECT s.seat_id, s.seat_number, s.seat_type, s.price
        FROM Seat s
        WHERE s.screen_id = %s
        AND s.seat_id NOT IN (
            SELECT tk.seat_id
            FROM Ticket tk
            INNER JOIN Booking b ON tk.booking_id = b.booking_id
            WHERE b.show_id = %s
        )
        ORDER BY s.seat_number
    """, (show['screen_id'], show_id))
    seats = cursor.fetchall()
    
    cursor.close()
    conn.close()
    return render_template('seat_selection.html', show=show, seats=seats)

# User login/register page
@app.route('/user', methods=['GET'])
def user_page():
    return render_template('user_form.html')

# Login route
@app.route('/login', methods=['POST'])
def login():
    email = request.form['email']
    password = request.form['password']
    
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    cursor.execute("SELECT user_id, password FROM User WHERE email = %s", (email,))
    user = cursor.fetchone()
    cursor.close()
    conn.close()
    
    if user and user['password'] == password:
        flash('Login successful!', 'success')
        return render_template('redirect_to_profile.html', user_id=user['user_id'])
    else:
        flash('Invalid email or password.', 'error')
        return redirect(url_for('user_page'))

# Register route
@app.route('/register', methods=['POST'])
def register():
    name = request.form['name']
    email = request.form['email']
    phone = request.form['phone']
    password = request.form['password']
    
    conn = get_db_connection()
    cursor = conn.cursor()
    try:
        cursor.execute("""
            INSERT INTO User (user_name, email, phone, password)
            VALUES (%s, %s, %s, %s)
        """, (name, email, phone, password))
        conn.commit()
        user_id = cursor.lastrowid
        flash('Registration successful!', 'success')
        cursor.close()
        conn.close()
        return render_template('redirect_to_profile.html', user_id=user_id)
    except mysql.connector.IntegrityError:
        flash('Email already registered. Please login instead.', 'error')
        cursor.close()
        conn.close()
        return redirect(url_for('user_page'))

# User profile with booking history
@app.route('/user/<int:user_id>')
def user_profile(user_id):
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    
    # Get user details
    cursor.execute("SELECT * FROM User WHERE user_id = %s", (user_id,))
    user = cursor.fetchone()
    
    if not user:
        flash('User not found', 'error')
        return redirect(url_for('index'))
    
    # Get booking history
    cursor.execute("""
        SELECT b.booking_id, m.title, t.theatre_name,
               st.showdate, st.show_time, p.amount, p.status,
               b.booking_date,
               GROUP_CONCAT(s.seat_number ORDER BY s.seat_number) AS seats
        FROM Booking b
        INNER JOIN ShowTable st ON b.show_id = st.show_id
        INNER JOIN Movie m ON st.movie_id = m.movie_id
        INNER JOIN Screen sc ON st.screen_id = sc.screen_id
        INNER JOIN Theatre t ON sc.theatre_id = t.theatre_id
        INNER JOIN Payment p ON b.booking_id = p.booking_id
        LEFT JOIN Ticket tk ON b.booking_id = tk.booking_id
        LEFT JOIN Seat s ON tk.seat_id = s.seat_id
        WHERE b.user_id = %s
        GROUP BY b.booking_id, m.title, t.theatre_name, st.showdate, 
                 st.show_time, p.amount, p.status, b.booking_date
        ORDER BY b.booking_date DESC
    """, (user_id,))
    bookings = cursor.fetchall()
    
    cursor.close()
    conn.close()
    
    return render_template('user_profile.html', user=user, bookings=bookings)

# Create booking
@app.route('/book', methods=['POST'])
def create_booking():
    data = request.json
    user_id = data.get('user_id')
    show_id = data.get('show_id')
    seat_ids = data.get('seat_ids')  # List of seat IDs
    
    if not user_id or not show_id or not seat_ids:
        return jsonify({'error': 'Missing required fields'}), 400
    
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    
    try:
        # Create booking
        cursor.execute("""
            INSERT INTO Booking (user_id, show_id, booking_date)
            VALUES (%s, %s, NOW())
        """, (user_id, show_id))
        booking_id = cursor.lastrowid
        
        # Calculate total amount and create tickets
        total_amount = 0
        for seat_id in seat_ids:
            # Get seat price
            cursor.execute("SELECT price FROM Seat WHERE seat_id = %s", (seat_id,))
            seat = cursor.fetchone()
            if seat:
                total_amount += float(seat['price'])
                
                # Create ticket
                cursor.execute("""
                    INSERT INTO Ticket (booking_id, seat_id)
                    VALUES (%s, %s)
                """, (booking_id, seat_id))
        
        # Create payment record
        cursor.execute("""
            INSERT INTO Payment (booking_id, amount, payment_date, payment_method, status)
            VALUES (%s, %s, NOW(), 'Pending', 'Pending')
        """, (booking_id, total_amount))
        
        conn.commit()
        cursor.close()
        conn.close()
        
        return jsonify({
            'success': True,
            'booking_id': booking_id,
            'total_amount': total_amount
        })
    except Exception as e:
        conn.rollback()
        cursor.close()
        conn.close()
        return jsonify({'error': str(e)}), 500

# Payment page
@app.route('/payment/<int:booking_id>')
def payment_page(booking_id):
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    
    cursor.execute("""
        SELECT b.booking_id, p.amount, m.title, st.showdate, st.show_time
        FROM Booking b
        INNER JOIN Payment p ON b.booking_id = p.booking_id
        INNER JOIN ShowTable st ON b.show_id = st.show_id
        INNER JOIN Movie m ON st.movie_id = m.movie_id
        WHERE b.booking_id = %s
    """, (booking_id,))
    booking = cursor.fetchone()
    
    cursor.close()
    conn.close()
    return render_template('payment.html', booking=booking)

# Process payment
@app.route('/process_payment', methods=['POST'])
def process_payment():
    booking_id = request.form['booking_id']
    payment_method = request.form['payment_method']
    
    conn = get_db_connection()
    cursor = conn.cursor()
    
    cursor.execute("""
        UPDATE Payment
        SET payment_method = %s, status = 'Success', payment_date = NOW()
        WHERE booking_id = %s
    """, (payment_method, booking_id))
    
    conn.commit()
    cursor.close()
    conn.close()
    
    flash('Payment successful! Booking confirmed.', 'success')
    return redirect(url_for('booking_confirmation', booking_id=booking_id))

# Booking confirmation
@app.route('/confirmation/<int:booking_id>')
def booking_confirmation(booking_id):
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    
    cursor.execute("""
        SELECT b.booking_id, m.title, t.theatre_name, 
               st.showdate, st.show_time, p.amount,
               GROUP_CONCAT(s.seat_number ORDER BY s.seat_number) AS seats
        FROM Booking b
        INNER JOIN ShowTable st ON b.show_id = st.show_id
        INNER JOIN Movie m ON st.movie_id = m.movie_id
        INNER JOIN Screen sc ON st.screen_id = sc.screen_id
        INNER JOIN Theatre t ON sc.theatre_id = t.theatre_id
        INNER JOIN Payment p ON b.booking_id = p.booking_id
        LEFT JOIN Ticket tk ON b.booking_id = tk.booking_id
        LEFT JOIN Seat s ON tk.seat_id = s.seat_id
        WHERE b.booking_id = %s
        GROUP BY b.booking_id, m.title, t.theatre_name, st.showdate, st.show_time, p.amount
    """, (booking_id,))
    
    booking = cursor.fetchone()
    cursor.close()
    conn.close()
    return render_template('confirmation.html', booking=booking)

# Admin dashboard
@app.route('/admin')
def admin_dashboard():
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    
    # Get statistics
    cursor.execute("SELECT COUNT(*) as total FROM Booking")
    total_bookings = cursor.fetchone()['total']
    
    cursor.execute("SELECT SUM(amount) as total FROM Payment WHERE status = 'Success'")
    total_revenue = cursor.fetchone()['total'] or 0
    
    # Most popular movies
    cursor.execute("""
        SELECT m.title, COUNT(DISTINCT b.booking_id) as bookings
        FROM Movie m
        INNER JOIN ShowTable st ON m.movie_id = st.movie_id
        INNER JOIN Booking b ON st.show_id = b.show_id
        GROUP BY m.movie_id, m.title
        ORDER BY bookings DESC
        LIMIT 5
    """)
    popular_movies = cursor.fetchall()
    
    # Get all movies for dropdown
    cursor.execute("SELECT movie_id, title FROM Movie ORDER BY title")
    all_movies = cursor.fetchall()
    
    # Get all screens for dropdown
    cursor.execute("""
        SELECT sc.screen_id, sc.screen_num, t.theatre_name
        FROM Screen sc
        INNER JOIN Theatre t ON sc.theatre_id = t.theatre_id
        ORDER BY t.theatre_name, sc.screen_num
    """)
    all_screens = cursor.fetchall()
    
    cursor.close()
    conn.close()
    
    return render_template('admin.html', 
                         total_bookings=total_bookings,
                         total_revenue=total_revenue,
                         popular_movies=popular_movies,
                         all_movies=all_movies,
                         all_screens=all_screens)

# Add movie route
@app.route('/admin/add_movie', methods=['POST'])
def add_movie():
    title = request.form['title']
    genre = request.form['genre']
    language = request.form['language']
    release_date = request.form['release_date']
    duration = request.form['duration']
    
    conn = get_db_connection()
    cursor = conn.cursor()
    
    try:
        cursor.execute("""
            INSERT INTO Movie (title, genre, language, ReleaseDate, duration)
            VALUES (%s, %s, %s, %s, %s)
        """, (title, genre, language, release_date, duration))
        conn.commit()
        flash('Movie added successfully!', 'success')
    except Exception as e:
        flash(f'Error adding movie: {str(e)}', 'error')
    finally:
        cursor.close()
        conn.close()
    
    return redirect(url_for('admin_dashboard'))

# Add show route
@app.route('/admin/add_show', methods=['POST'])
def add_show():
    movie_id = request.form['movie_id']
    screen_id = request.form['screen_id']
    showdate = request.form['showdate']
    show_time = request.form['show_time']
    
    # Combine date and time
    show_datetime = f"{showdate} {show_time}:00"
    
    conn = get_db_connection()
    cursor = conn.cursor()
    
    try:
        cursor.execute("""
            INSERT INTO ShowTable (screen_id, movie_id, showdate, show_time)
            VALUES (%s, %s, %s, %s)
        """, (screen_id, movie_id, showdate, show_datetime))
        conn.commit()
        flash('Show added successfully!', 'success')
    except Exception as e:
        flash(f'Error adding show: {str(e)}', 'error')
    finally:
        cursor.close()
        conn.close()
    
    return redirect(url_for('admin_dashboard'))

if __name__ == '__main__':
    app.run(debug=True)