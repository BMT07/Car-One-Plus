import 'package:flutter/material.dart';
import '../models/review.dart';
import '../services/review_service.dart';

class ReviewForm extends StatefulWidget {
  final int vehicleId;
  final Function(Map<String, dynamic>) onReviewSubmitted;
  final ReviewService reviewService;

  const ReviewForm({
    Key? key,
    required this.vehicleId,
    required this.onReviewSubmitted,
    required this.reviewService,
  }) : super(key: key);

  @override
  _ReviewFormState createState() => _ReviewFormState();
}

class _ReviewFormState extends State<ReviewForm> {
  final _formKey = GlobalKey<FormState>();
  final _commentController = TextEditingController();
  int _rating = 0;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Donnez votre avis',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          Text('Note:'),
          Row(
            children: List.generate(5, (index) {
              return IconButton(
                icon: Icon(
                  index < _rating ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                ),
                onPressed: () {
                  setState(() {
                    _rating = index + 1;
                  });
                },
              );
            }),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _commentController,
            decoration: InputDecoration(
              labelText: 'Commentaire',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez entrer un commentaire';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSubmitting
                  ? null
                  : () async {
                if (_formKey.currentState!.validate() && _rating > 0) {
                  setState(() {
                    _isSubmitting = true;
                  });
                  try {
                    final result = await widget.reviewService.createReview(
                      vehicleId: widget.vehicleId,
                      rating: _rating,
                      comment: _commentController.text,
                    );
                    widget.onReviewSubmitted(result);
                    _commentController.clear();
                    setState(() {
                      _rating = 0;
                      _isSubmitting = false;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Avis ajouté avec succès')),
                    );
                  } catch (e) {
                    setState(() {
                      _isSubmitting = false;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(e.toString())),
                    );
                  }
                } else if (_rating == 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Veuillez attribuer une note')),
                  );
                }
              },
              child: _isSubmitting
                  ? const CircularProgressIndicator()
                  : const Text('Soumettre'),
            ),
          ),
        ],
      ),
    );
  }
}

class ReviewsList extends StatelessWidget {
  final List<Map<String, dynamic>> reviews;
  final double? averageRating;
  final int? totalReviews;
  final bool showVehicleInfo;
  final Function(int)? onDeleteReview;
  final bool isUserReviews;

  const ReviewsList({
    Key? key,
    required this.reviews,
    this.averageRating,
    this.totalReviews,
    this.showVehicleInfo = false,
    this.onDeleteReview,
    this.isUserReviews = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (averageRating != null && totalReviews != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Row(
              children: [
                Text(
                  averageRating!.toStringAsFixed(1),
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(width: 8),
                Row(
                  children: List.generate(5, (index) {
                    return Icon(
                      index < averageRating! ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                    );
                  }),
                ),
                const SizedBox(width: 8),
                Text('($totalReviews avis)'),
              ],
            ),
          ),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: reviews.length,
          itemBuilder: (context, index) {
            final review = Review.fromJson(reviews[index]);
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${review.userFname} ${review.userLname}' ?? 'Utilisateur anonyme',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              Text(
                                '${review.createdAt.day}/${review.createdAt.month}/${review.createdAt.year}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        if (onDeleteReview != null && isUserReviews)
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text('Confirmer la suppression'),
                                  content: Text('Êtes-vous sûr de vouloir supprimer cet avis ?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(context).pop(),
                                      child: Text('Annuler'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                        onDeleteReview!(review.id!);
                                      },
                                      child: Text('Supprimer'),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: List.generate(5, (index) {
                        return Icon(
                          index < review.rating ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 20,
                        );
                      }),
                    ),
                    if (showVehicleInfo && review.vehicleName != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Véhicule: ${review.vehicleName}',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ],
                    const SizedBox(height: 8),
                    Text(review.comment),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class VehicleReviewsScreen extends StatefulWidget {
  final int vehicleId;
  final String vehicleName;

  const VehicleReviewsScreen({
    Key? key,
    required this.vehicleId,
    required this.vehicleName,
  }) : super(key: key);

  @override
  _VehicleReviewsScreenState createState() => _VehicleReviewsScreenState();
}

class _VehicleReviewsScreenState extends State<VehicleReviewsScreen> {
  final ReviewService _reviewService = ReviewService();
  late Future<Map<String, dynamic>> _reviewsFuture;
  int _currentPage = 1;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews({bool refresh = false}) async {
    if (refresh) {
      setState(() {
        _currentPage = 1;
      });
    }

    setState(() {
      _reviewsFuture = _reviewService.getVehicleReviews(
        vehicleId: widget.vehicleId,
        page: _currentPage,
      );
    });
  }

  void _handleReviewSubmitted(Map<String, dynamic> result) {
    _loadReviews(refresh: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Avis - ${widget.vehicleName}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ReviewForm(
              vehicleId: widget.vehicleId,
              onReviewSubmitted: _handleReviewSubmitted,
              reviewService: _reviewService,
            ),
            const Divider(height: 32),
            FutureBuilder<Map<String, dynamic>>(
              future: _reviewsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting && !_isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text('Erreur: ${snapshot.error}'),
                  );
                }

                if (!snapshot.hasData) {
                  return const Center(
                    child: Text('Aucun avis pour le moment'),
                  );
                }

                final data = snapshot.data!;
                final reviews = data['reviews'] as List<dynamic>;
                final totalPages = data['total_pages'] as int;

                return Column(
                  children: [
                    ReviewsList(
                      reviews: reviews.cast<Map<String, dynamic>>(),
                      averageRating: data['average_rating'],
                      totalReviews: data['total_reviews'],
                    ),
                    if (totalPages > 1)
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: _currentPage > 1
                                  ? () {
                                setState(() {
                                  _currentPage--;
                                  _isLoading = true;
                                });
                                _loadReviews().then((_) {
                                  setState(() {
                                    _isLoading = false;
                                  });
                                });
                              }
                                  : null,
                              child: const Text('Précédent'),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Text('$_currentPage / $totalPages'),
                            ),
                            ElevatedButton(
                              onPressed: _currentPage < totalPages
                                  ? () {
                                setState(() {
                                  _currentPage++;
                                  _isLoading = true;
                                });
                                _loadReviews().then((_) {
                                  setState(() {
                                    _isLoading = false;
                                  });
                                });
                              }
                                  : null,
                              child: const Text('Suivant'),
                            ),
                          ],
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class UserReviewsScreen extends StatefulWidget {
  final int userId;

  const UserReviewsScreen({
    Key? key,
    required this.userId,
  }) : super(key: key);

  @override
  _UserReviewsScreenState createState() => _UserReviewsScreenState();
}

class _UserReviewsScreenState extends State<UserReviewsScreen> {
  final ReviewService _reviewService = ReviewService();
  late Future<Map<String, dynamic>> _reviewsFuture;
  int _currentPage = 1;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews({bool refresh = false}) async {
    if (refresh) {
      setState(() {
        _currentPage = 1;
      });
    }

    setState(() {
      _reviewsFuture = _reviewService.getUserReviews(
        userId: widget.userId,
        page: _currentPage,
      );
    });
  }

  Future<void> _handleDeleteReview(int reviewId) async {
    try {
      await _reviewService.deleteReview(reviewId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Avis supprimé avec succès')),
      );
      _loadReviews(refresh: true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Mes avis'),
        ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FutureBuilder<Map<String, dynamic>>(
              future: _reviewsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting && !_isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text('Erreur: ${snapshot.error}'),
                  );
                }

                if (!snapshot.hasData) {
                  return const Center(
                    child: Text('Vous n\'avez pas encore laissé d\'avis'),
                  );
                }

                final data = snapshot.data!;
                final reviews = data['reviews'] as List<dynamic>;
                final totalPages = data['total_pages'] as int;

                if (reviews.isEmpty) {
                  return const Center(
                    child: Text('Vous n\'avez pas encore laissé d\'avis'),
                  );
                }

                return Column(
                  children: [
                    ReviewsList(
                      reviews: reviews.cast<Map<String, dynamic>>(),
                      showVehicleInfo: true,
                      onDeleteReview: _handleDeleteReview,
                      isUserReviews: true,
                    ),
                    if (totalPages > 1)
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: _currentPage > 1
                                  ? () {
                                setState(() {
                                  _currentPage--;
                                  _isLoading = true;
                                });
                                _loadReviews().then((_) {
                                  setState(() {
                                    _isLoading = false;
                                  });
                                });
                              }
                                  : null,
                              child: const Text('Précédent'),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Text('$_currentPage / $totalPages'),
                            ),
                            ElevatedButton(
                              onPressed: _currentPage < totalPages
                                  ? () {
                                setState(() {
                                  _currentPage++;
                                  _isLoading = true;
                                });
                                _loadReviews().then((_) {
                                  setState(() {
                                    _isLoading = false;
                                  });
                                });
                              }
                                  : null,
                              child: const Text('Suivant'),
                            ),
                          ],
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// Widget pour afficher la note moyenne d'un véhicule (à utiliser dans la liste des véhicules ou la page détail)
class AverageRatingWidget extends StatelessWidget {
  final int vehicleId;
  final ReviewService reviewService;

  const AverageRatingWidget({
    Key? key,
    required this.vehicleId,
    required this.reviewService,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: reviewService.getVehicleReviews(vehicleId: vehicleId, perPage: 1),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return Row(
            children: const [
              Icon(Icons.star_border, size: 16, color: Colors.grey),
              SizedBox(width: 4),
              Text('N/A', style: TextStyle(color: Colors.grey)),
            ],
          );
        }

        final data = snapshot.data!;
        final rating = data['average_rating'] as double?;
        final totalReviews = data['total_reviews'] as int;

        if (rating == null) {
          return Row(
            children: const [
              Icon(Icons.star_border, size: 16, color: Colors.grey),
              SizedBox(width: 4),
              Text('Aucun avis', style: TextStyle(color: Colors.grey)),
            ],
          );
        }

        return Row(
          children: [
            Row(
              children: List.generate(5, (index) {
                return Icon(
                  index < rating ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                  size: 16,
                );
              }),
            ),
            const SizedBox(width: 4),
            Text('$rating ($totalReviews)'),
          ],
        );
      },
    );
  }
}