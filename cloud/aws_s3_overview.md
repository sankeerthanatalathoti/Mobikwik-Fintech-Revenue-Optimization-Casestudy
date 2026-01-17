## Cloud Storage Layer – AWS S3 (Conceptual)

This project follows a cloud-enabled analytics design where cloud storage is used
as a scalable and centralized data layer.

### Purpose of Cloud Layer
- Acts as the raw and intermediate data storage layer
- Enables separation between data ingestion and analytics
- Mimics real-world fintech data pipelines

### Conceptual Cloud Flow
- Source data is assumed to be stored in object storage (AWS S3)
- Data is downloaded as flat files (CSV / Excel) for analysis
- Files are then ingested into a relational database for modeling

> Note:
> Due to account access limitations, AWS S3 integration is represented
> conceptually. The architecture reflects real-world production design
> patterns used in analytics systems.

### Why AWS S3 (Industry Context)
- Highly scalable object storage
- Cost-efficient for large transactional datasets
- Commonly used with SQL engines, Python pipelines, and BI tools

### Cloud-Agnostic Design
Although AWS S3 is referenced, the same architecture can be implemented using:
- Azure Blob Storage
- Google Cloud Storage

The design remains portable across cloud providers.

